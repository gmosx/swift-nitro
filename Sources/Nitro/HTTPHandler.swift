// requestDidReceiveHead
// requestDidReceiveBody
// requestDidEnd
// writeHead
// writeBody
// writeEnd
// flush

open class HTTPHandler: ChannelInboundHandler {
    public typealias InboundIn = HTTPServerRequestPart
    public var context: ChannelHandlerContext!
    public var requestHead: HTTPRequestHead!

    public init() {
    }

    open func didReceiveHead(requestHead: HTTPRequestHead) {
    }

    open func didReceiveBody(requestBody: ByteBuffer) {
    }

    open func didReceiveEnd(requestEndHeaders: HTTPHeaders?) {
    }

    public func write(part: HTTPServerResponsePart) {
        _ = context.channel.write(part)
    }

    public func writeAndClose(part: HTTPServerResponsePart) {
        _ = context.channel.writeAndFlush(part).then {
            self.context.channel.close()
        }
    }

    public func writeHead(version: HTTPVersion? = nil, status: HTTPResponseStatus = .ok, headers: HTTPHeaders? = nil) {
        let head: HTTPResponseHead

        if let headers = headers {
            head = HTTPResponseHead(
                version: version ?? requestHead.version,
                status: status,
                headers: headers
            )
        } else {
            head = HTTPResponseHead(
                version: version ?? requestHead.version,
                status: status
            )
        }

        write(part: HTTPServerResponsePart.head(head))
    }

    public func writeBody(_ text: String) {
        var buffer = context.channel.allocator.buffer(capacity: text.utf8.count)
        buffer.write(string: text)
        write(part: HTTPServerResponsePart.body(.byteBuffer(buffer)))
    }

    public func close() {
        let endpart = HTTPServerResponsePart.end(nil)
        writeAndClose(part: endpart)
    }

    open func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        context = ctx

        let requestPart = unwrapInboundIn(data)

        switch requestPart {
        case .head(let requestHead):
            self.requestHead = requestHead
            didReceiveHead(requestHead: requestHead)

        case .body(let requestBody):
            didReceiveBody(requestBody: requestBody)

        case .end(let requestEndHeaders):
            didReceiveEnd(requestEndHeaders: requestEndHeaders)
        }
    }
}
