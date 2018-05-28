import NIO
import NIOHTTP1

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

    @discardableResult
    public func write(part: HTTPServerResponsePart) -> EventLoopFuture<Void> {
        return ctx.channel.write(wrapOutboundOut(part))
    }

    @discardableResult
    public func writeAndFlush(part: HTTPServerResponsePart) -> EventLoopFuture<Void> {
        return ctx.channel.writeAndFlush(wrapOutboundOut(part))
    }

    public func writeAndFlush(part: HTTPServerResponsePart, promise: EventLoopPromise<Void>? = nil) {
        return ctx.channel.writeAndFlush(wrapOutboundOut(part), promise: promise)
    }

    public func writeAndClose(part: HTTPServerResponsePart) {
        _ = ctx.channel.writeAndFlush(wrapOutboundOut(part)).then {
            self.ctx.channel.close()
        }
    }

    public func writeHead(version: HTTPVersion? = nil, status: HTTPResponseStatus = .ok, contentType: String = "text/html; charset=utf-8", headers: HTTPHeaders? = nil) {
        let head: HTTPResponseHead

        if var headers = headers {
            if !headers.contains(name: "Content-Type") {
                headers.add(name: "Content-Type", value: contentType)
            }
            if !requestHead.isKeepAlive && (!headers.contains(name: "Content-Type")) {
                headers.add(name: "Connection", value: "close")
            }

            head = HTTPResponseHead(
                version: version ?? requestHead.version,
                status: status,
                headers: headers
            )
        } else {
            var headers = HTTPHeaders()
            headers.add(name: "Content-Type", value: contentType)
            if !requestHead.isKeepAlive {
                headers.add(name: "Connection", value: "close")
            }
            head = HTTPResponseHead(
                version: version ?? requestHead.version,
                status: status,
                headers: headers
            )
        }

        write(part: .head(head))
    }

    @discardableResult
    public func writeBody(_ text: String) -> EventLoopFuture<Void> {
        var buffer = ctx.channel.allocator.buffer(capacity: text.utf8.count)
        buffer.write(string: text)
        return write(part: .body(.byteBuffer(buffer)))
    }

    @discardableResult
    public func writeBody(_ buffer: ByteBuffer) -> EventLoopFuture<Void> {
        return write(part: .body(.byteBuffer(buffer)))
    }

    @discardableResult
    public func writeBody(_ region: FileRegion) -> EventLoopFuture<Void> {
        return write(part: .body(.fileRegion(region)))
    }

    public func writeEnd(trailers: HTTPHeaders? = nil) {
        let endpart = HTTPServerResponsePart.end(trailers)

        if requestHead.isKeepAlive {
            writeAndFlush(part: endpart)
        } else {
            writeAndClose(part: endpart)
        }
    }

    public func flush() {
        ctx.channel.flush()
    }

    public func redirect(to location: String, status: HTTPResponseStatus = .temporaryRedirect) {
        var responseHeaders = HTTPHeaders()
        responseHeaders.add(name: "Location", value: location)
        self.writeHead(status: status, headers: responseHeaders)
        self.writeEnd()
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
