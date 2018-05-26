import Nitro

class HomeHandler: HTTPHandler {
    override func didReceive(requestHead: HTTPRequestHead, ctx: ChannelHandlerContext) {
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: "Content-Type", value: "text/html")
        let head = HTTPResponseHead(
            version: requestHead.version,
            status: .ok,
            headers: headers
        )
        let headpart = HTTPServerResponsePart.head(head)
        _ = ctx.channel.write(headpart)

        let text = "Welcome home! <a href=\"/hello\">Hello</a>"

        var buffer = ctx.channel.allocator.buffer(capacity: text.utf8.count)
        buffer.write(string: text)
        let bodypart = HTTPServerResponsePart.body(.byteBuffer(buffer))
        _ = ctx.channel.write(bodypart)

        let endpart = HTTPServerResponsePart.end(nil)
        _ = ctx.channel.writeAndFlush(endpart).then {
            ctx.channel.close()
        }
    }
}

class HelloHandler: HTTPHandler {
    override func didReceive(requestHead: HTTPRequestHead, ctx: ChannelHandlerContext) {
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: "Content-Type", value: "text/html")
        let head = HTTPResponseHead(
            version: requestHead.version,
            status: .ok,
            headers: headers
        )
        let headpart = HTTPServerResponsePart.head(head)
        _ = ctx.channel.write(headpart)

        let text = "Hello World! YEAH! <a href=\"/\">Home</a>"

        var buffer = ctx.channel.allocator.buffer(capacity: text.utf8.count)
        buffer.write(string: text)
        let bodypart = HTTPServerResponsePart.body(.byteBuffer(buffer))
        _ = ctx.channel.write(bodypart)

        let endpart = HTTPServerResponsePart.end(nil)
        _ = ctx.channel.writeAndFlush(endpart).then {
            ctx.channel.close()
        }
    }
}

let router = Router()
router.routes["/"] = HomeHandler()
router.routes["/hello"] = HelloHandler()

let server = HTTPServer(handler: router)
server.bind(host: "localhost", port: 1337)
