import Nitro

class HomeHandler: HTTPHandler {
    override func didReceive(requestHead: HTTPRequestHead) {
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: "Content-Type", value: "text/html")
        let head = HTTPResponseHead(
            version: requestHead.version,
            status: .ok,
            headers: headers
        )
        let headpart = HTTPServerResponsePart.head(head)
        write(part: headpart)

        let text = "Welcome home! <a href=\"/hello\">Hello</a>"

        var buffer = context.channel.allocator.buffer(capacity: text.utf8.count)
        buffer.write(string: text)
        let bodypart = HTTPServerResponsePart.body(.byteBuffer(buffer))
        write(part: bodypart)

        let endpart = HTTPServerResponsePart.end(nil)
        writeAndClose(part: endpart)
    }
}

class HelloHandler: HTTPHandler {
    override func didReceive(requestHead: HTTPRequestHead) {
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: "Content-Type", value: "text/html")
        let head = HTTPResponseHead(
            version: requestHead.version,
            status: .ok,
            headers: headers
        )
        let headpart = HTTPServerResponsePart.head(head)
        write(part: headpart)

        let text = "Hello World! YEAH! <a href=\"/\">Home</a>"

        var buffer = context.channel.allocator.buffer(capacity: text.utf8.count)
        buffer.write(string: text)
        let bodypart = HTTPServerResponsePart.body(.byteBuffer(buffer))
        write(part: bodypart)

        let endpart = HTTPServerResponsePart.end(nil)
        writeAndClose(part: endpart)
    }
}

let router = Router()
router.routes["/"] = HomeHandler()
router.routes["/hello"] = HelloHandler()

let server = HTTPServer(handler: router)
server.bind(host: "localhost", port: 1337)
