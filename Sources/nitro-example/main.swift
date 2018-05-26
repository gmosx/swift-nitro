import Nitro

class HomeHandler: HTTPHandler {
    override func didReceiveHead(requestHead: HTTPRequestHead) {
        var responseHeaders = HTTPHeaders()
        responseHeaders.add(name: "Content-Type", value: "text/html")

        writeHead(status: .ok, headers: responseHeaders)
        writeBody("Welcome home! <a href=\"/hello\">Hello</a>")
        close()
    }
}

class HelloHandler: HTTPHandler {
    override func didReceiveHead(requestHead: HTTPRequestHead) {
        var responseHeaders = HTTPHeaders()
        responseHeaders.replaceOrAdd(name: "Content-Type", value: "text/html")

        writeHead(headers: responseHeaders)
        writeBody("Hello World! YEAH! <a href=\"/\">Home</a>")
        close()
    }
}

let router = Router()
router.route(path: "/", to: HomeHandler())
router.route(path: "/hello", to: HelloHandler())

let server = HTTPServer(handler: router)
server.bind(host: "localhost", port: 1337)
