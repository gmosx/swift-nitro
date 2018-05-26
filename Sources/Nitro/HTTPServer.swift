import Foundation
import NIO
import NIOHTTP1

open class HTTPServer {
    let loopGroup = MultiThreadedEventLoopGroup(numThreads: System.coreCount)
    let handler: HTTPHandler

    public init(handler: HTTPHandler) {
        self.handler = handler
    }

    open func bind(host: String, port: Int) {
        let reuseAddrOption = ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR)

        let bootstrap = ServerBootstrap(group: loopGroup)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(reuseAddrOption, value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.configureHTTPServerPipeline(withErrorHandling: true).then {
                    channel.pipeline.add(handler: self.handler)
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
