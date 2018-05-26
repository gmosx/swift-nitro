import Nitro

class HomeHandler: HTTPHandler {
    override func didReceive(requestHead: HTTPRequestHead) {
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: "Content-Type", value: "text/html")

        writeHead(status: .ok, headers: headers)

        write(body: "Welcome home! <a href=\"/hello\">Hello</a>")

        let endpart = HTTPServerResponsePart.end(nil)
        writeAndClose(part: endpart)
    }
}

class HelloHandler: HTTPHandler {
    override func didReceive(requestHead: HTTPRequestHead) {
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: "Content-Type", value: "text/html")

        writeHead(status: .ok, headers: headers)

        write(body: "Hello World! YEAH! <a href=\"/\">Home</a>")

        let endpart = HTTPServerResponsePart.end(nil)
        writeAndClose(part: endpart)
    }
}

let router = Router()
router.routes["/"] = HomeHandler()
router.routes["/hello"] = HelloHandler()

let server = HTTPServer(handler: router)
server.bind(host: "localhost", port: 1337)
