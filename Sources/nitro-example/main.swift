import Nitro

class HomeHandler: HTTPHandler {
    override func didReceive(requestHead: HTTPRequestHead) {
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: "Content-Type", value: "text/html")

        writeHead(status: .ok, headers: headers)
        writeBody("Welcome home! <a href=\"/hello\">Hello</a>")
        close()
    }
}

class HelloHandler: HTTPHandler {
    override func didReceive(requestHead: HTTPRequestHead) {
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: "Content-Type", value: "text/html")

        writeHead(headers: headers)
        writeBody("Hello World! YEAH! <a href=\"/\">Home</a>")
        close()
    }
}

let router = Router()
router.routes["/"] = HomeHandler()
router.routes["/hello"] = HelloHandler()

let server = HTTPServer(handler: router)
server.bind(host: "localhost", port: 1337)
