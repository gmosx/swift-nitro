import Nitro

class HomeHandler: HTTPHandler {
    override func didReceiveHead(requestHead: HTTPRequestHead) {
        let cookie1 = requestHead.headers.cookie(named: "cookie1")
        let cookie2 = requestHead.headers.cookie(named: "cookie2")

        writeHead(status: .ok, contentType: "text/html; charset=utf-8")

        writeBody(
            """
            Welcome home! <a href=\"/hello\">Hello</a><br />
            Here are your cookies: \(cookie1 ?? "-"), \(cookie2 ?? "-")
            """
        )

        writeEnd()
    }
}

class HelloHandler: HTTPHandler {
    override func didReceiveHead(requestHead: HTTPRequestHead) {
        var responseHeaders = HTTPHeaders()
        responseHeaders.addCookie(name: "cookie1", value: "It works")
        responseHeaders.addCookie(name: "cookie2", value: "2013")
        responseHeaders.removeCookie(named: "gmcookie")

        writeHead(status: .ok, headers: responseHeaders)

        writeBody("Hello World! YEAH! <a href=\"/\">Home</a><img src=\"reizu-mark.svg\" />")
        
        writeEnd()
    }
}

let staticFileRootPath = "/\(#file.split(separator: "/").dropLast().joined(separator: "/"))/public"
let staticFileHandler = StaticFileHandler(rootPath: staticFileRootPath)

let router = Router()
router.addRule(pattern: "/") { HomeHandler() }
router.addRule(pattern: "/hello") { HelloHandler() }
router.fallback { staticFileHandler }

let server = HTTPServer(handler: router)
server.bind(host: "localhost", port: 1337)
