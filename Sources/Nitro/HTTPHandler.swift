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

    public init() {
    }

    open func didReceive(requestHead: HTTPRequestHead) {
    }

    public func write(part: HTTPServerResponsePart) {
        _ = context.channel.write(part)
    }

    public func writeAndClose(part: HTTPServerResponsePart) {
        _ = context.channel.writeAndFlush(part).then {
            self.context.channel.close()
        }
    }

    open func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        context = ctx

        let requestPart = unwrapInboundIn(data)

        switch requestPart {
        case .head(let requestHead):
            didReceive(requestHead: requestHead)
//            print("req:", header)
//
//            var headers = HTTPHeaders()
//            headers.replaceOrAdd(name: "Content-Type", value: "text/html")
//            let head = HTTPResponseHead(
//                version: header.version,
//                status: .ok,
//                headers: headers
//            )
//            let headpart = HTTPServerResponsePart.head(head)
//            _ = ctx.channel.write(headpart)
//
//            let text = "Hello"
//
//            var buffer = ctx.channel.allocator.buffer(capacity: text.utf8.count)
//            buffer.write(string: text)
//            let bodypart = HTTPServerResponsePart.body(.byteBuffer(buffer))
//            _ = ctx.channel.write(bodypart)
//
//            let endpart = HTTPServerResponsePart.end(nil)
//            _ = ctx.channel.writeAndFlush(endpart).then {
//                ctx.channel.close()
//            }

        case .body, .end:
            break
        }
    }
}
