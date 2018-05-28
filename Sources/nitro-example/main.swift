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

let staticFileRootPath = "/\(#file.split(separator: "/").dropLast().joined(separator: "/"))/public"
let staticFileHandler = StaticFileHandler(rootPath: staticFileRootPath)

let router = Router()
router.addRule(pattern: "/") { HomeHandler() }
router.addRule(pattern: "/hello") { HelloHandler() }
router.addRule(defaultHandler: { staticFileHandler })

let server = HTTPServer(handler: router)
server.bind(host: "localhost", port: 1337)
