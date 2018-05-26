// requestDidReceiveHead
// requestDidReceiveBody
// requestDidEnd
// writeHead
// writeBody
// writeEnd
// flush

open class HTTPHandler: ChannelInboundHandler {
    public typealias InboundIn = HTTPServerRequestPart

    public init() {
    }

    open func didReceive(requestHead: HTTPRequestHead, ctx: ChannelHandlerContext) {
    }
    
    open func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let requestPart = unwrapInboundIn(data)

        switch requestPart {
        case .head(let requestHead):
            didReceive(requestHead: requestHead, ctx: ctx)
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
