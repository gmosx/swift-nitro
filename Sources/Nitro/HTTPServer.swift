import Foundation
import NIO
import NIOHTTP1

// TODO: need other name

open class HTTPServer {
    final class HTTPHandler: ChannelInboundHandler {
        typealias InboundIn = HTTPServerRequestPart

        func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
            let reqPart = unwrapInboundIn(data)

            switch reqPart {
            case .head(let header):
                print("req:", header)

                var headers = HTTPHeaders()
                headers.replaceOrAdd(name: "Content-Type", value: "text/html")
                let head = HTTPResponseHead(
                    version: header.version,
                    status: .ok,
                    headers: headers
                )
                let headpart = HTTPServerResponsePart.head(head)
                _ = ctx.channel.write(headpart)

                let text: String
                if header.uri.hasPrefix("/hello") {
                    text = "Hello World! YEAH! <a href=\"/\">Home</a>"
                } else {
                    text = "Go away! <a href=\"/hello\">Hello</a>"
                }

                var buffer = ctx.channel.allocator.buffer(capacity: text.utf8.count)
                buffer.write(string: text)
                let bodypart = HTTPServerResponsePart.body(.byteBuffer(buffer))
                _ = ctx.channel.write(bodypart)

                let endpart = HTTPServerResponsePart.end(nil)
                _ = ctx.channel.writeAndFlush(endpart).then {
                  ctx.channel.close()
                }

            case .body, .end:
                break
            }
        }
    }

    let loopGroup = MultiThreadedEventLoopGroup(numThreads: System.coreCount)

    public init() {
    }

    open func bind(host: String, port: Int) {
        let reuseAddrOption = ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR)
        let bootstrap = ServerBootstrap(group: loopGroup)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(reuseAddrOption, value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.configureHTTPServerPipeline(withErrorHandling: true).then {
                    channel.pipeline.add(handler: HTTPHandler())
                }
            }
            .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .childChannelOption(reuseAddrOption, value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)

        do {
            let serverChannel = try bootstrap.bind(host: host, port: port).wait()
            print("Server running on:", serverChannel.localAddress!)
            try serverChannel.closeFuture.wait() // runs forever
        } catch {
            fatalError("Failed to start server: \(error)")
        }
    }
}
