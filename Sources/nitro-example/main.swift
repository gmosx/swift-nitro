import Nitro

class HomeHandler: HTTPHandler {
    override func didReceiveHead(requestHead: HTTPRequestHead) {
        writeHead(status: .ok, contentType: "text/html")
        writeBody("Welcome home! <a href=\"/hello\">Hello</a>")
        writeEndAndClose()
    }
}

class HelloHandler: HTTPHandler {
    override func didReceiveHead(requestHead: HTTPRequestHead) {
        writeHead(status: .ok, contentType: "text/html")
        writeBody("Hello World! YEAH! <a href=\"/\">Home</a>")
        writeEndAndClose()
    }
}

let router = Router()
router.route(path: "/", to: HomeHandler())
router.route(path: "/hello", to: HelloHandler())

let server = HTTPServer(handler: router)
server.bind(host: "localhost", port: 1337)
