import NIO
import NIOHTTP1

// TODO: correctly handle keepalive

open class HTTPHandler: ChannelInboundHandler {
    public typealias InboundIn = HTTPServerRequestPart
    public typealias OutboundOut = HTTPServerResponsePart
    
    public var ctx: ChannelHandlerContext!
    public var requestHead: HTTPRequestHead!

    public init() {
    }

    open func didReceiveHead(requestHead: HTTPRequestHead) {
    }

    open func didReceiveBody(requestBody: ByteBuffer) {
    }

    open func didReceiveEnd(requestTrailers: HTTPHeaders?) {
    }

    public func write(part: HTTPServerResponsePart) {
        _ = ctx.channel.write(part)
    }

    public func writeAndClose(part: HTTPServerResponsePart) {
        _ = ctx.channel.writeAndFlush(part).then {
            self.ctx.channel.close()
        }
    }

    public func writeHead(version: HTTPVersion? = nil, status: HTTPResponseStatus = .ok, contentType: String = "text/html", headers: HTTPHeaders? = nil) {
        let head: HTTPResponseHead

        if var headers = headers {
            if !headers.contains(name: "Content-Type") {
                headers.add(name: "Content-Type", value: contentType)
            }

            head = HTTPResponseHead(
                version: version ?? requestHead.version,
                status: status,
                headers: headers
            )
        } else {
            var headers = HTTPHeaders()
            headers.add(name: "Content-Type", value: contentType)
            head = HTTPResponseHead(
                version: version ?? requestHead.version,
                status: status,
                headers: headers
            )
        }

        write(part: HTTPServerResponsePart.head(head))
    }

    public func writeBody(_ text: String) {
        var buffer = ctx.channel.allocator.buffer(capacity: text.utf8.count)
        buffer.write(string: text)
        write(part: HTTPServerResponsePart.body(.byteBuffer(buffer)))
    }

    public func flush() {
        ctx.channel.flush()
    }

    public func writeEndAndClose(trailers: HTTPHeaders? = nil) {
        let endpart = HTTPServerResponsePart.end(trailers)
        writeAndClose(part: endpart)
    }

    open func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        self.ctx = ctx

        let requestPart = unwrapInboundIn(data)

        switch requestPart {
        case .head(let requestHead):
            self.requestHead = requestHead
            didReceiveHead(requestHead: requestHead)

        case .body(let requestBody):
            didReceiveBody(requestBody: requestBody)

        case .end(let requestTrailers):
            didReceiveEnd(requestTrailers: requestTrailers)
        }
    }
}
