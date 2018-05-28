import Nitro

class HomeHandler: HTTPHandler {
    override func didReceiveHead(requestHead: HTTPRequestHead) {
        writeHead(status: .ok, contentType: "text/html; charset=utf-8")
        writeBody("Welcome home! <a href=\"/hello\">Hello</a>")
        writeEnd()
    }
}

class HelloHandler: HTTPHandler {
    override func didReceiveHead(requestHead: HTTPRequestHead) {
        writeHead(status: .ok)
        writeBody("Hello World! YEAH! <a href=\"/\">Home</a><img src=\"reizu-mark.svg\" />")
        writeEnd()
    }
}

let rootPath = "/\(#file.split(separator: "/").dropLast().joined(separator: "/"))/public"
let staticFileHandler = StaticFileHandler(rootPath: rootPath)

let router = Router(defaultHandler: staticFileHandler)
router.addRule(pattern: "/", handler: HomeHandler())
router.addRule(pattern: "/hello", handler: HelloHandler())

let server = HTTPServer(handler: router)
server.bind(host: "localhost", port: 1337)
