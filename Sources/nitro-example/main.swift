import Foundation
import Logging
import Nitro

// TODO: Add example with POST json
// TODO: Add example with POST file
// TODO: Add file-upload example

class HomeHandler: HTTPHandler {
    override func headRead(requestHead: HTTPRequestHead) {
        let cookie1 = requestHead.headers.cookie(named: "cookie1")
        let cookie2 = requestHead.headers.cookie(named: "cookie2")

        writeHead(status: .ok, contentType: "text/html; charset=utf-8")

        writeBody(
            """
            Welcome home! <a href=\"/hello\">Hello</a><br />
            Here are your cookies: \(cookie1 ?? "-"), \(cookie2 ?? "-")
            <br /><br /><br />
            Go to <a href="/profiles/15">Profile</a>
            <br /><br /><br />
            <form method="post" action="/handle-form">
                <p>
                    <label>Username</label><br />
                    <input type="text" name="username">
                </p>
                <p>
                    <label>Password</label><br />
                    <input type="password" name="password">
                </p>
                <p>
                    <button type="submit">Send</button>
                </p>
            </form>
            """
        )

        writeEnd()
    }
}

class HelloHandler: HTTPHandler {
    override func headRead(requestHead: HTTPRequestHead) {
        var responseHeaders = HTTPHeaders()
        responseHeaders.addCookie(name: "cookie1", value: "It works", httpOnly: true)
        responseHeaders.addCookie(name: "cookie2", value: "2013")
        responseHeaders.removeCookie(named: "gmcookie")

        writeHead(status: .ok, headers: responseHeaders)

        writeBody(
            """
            Hello World! YEAH! <a href="/">Home</a><img src="reizu-mark.svg" />
            <br />
            <br />
            <a href="/streaming">Streaming</a>
            """
        )

        writeEnd()
    }
}

class StreamingHandler: HTTPHandler {
    override func headRead(requestHead: HTTPRequestHead) {
        writeHead(status: .ok)

        for i in 0..<10 {
            writeBody("Ping \(i)<br />")
            flush()
            sleep(1) // I know it's BAAAAAD, but that's just a demo!
        }

        writeEnd()
    }
}

class ProfileHandler: HTTPHandler {
    let id: String
    
    public init(id: String) {
        self.id = id
    }
    
    override func headRead(requestHead: HTTPRequestHead) {
        writeHead(status: .ok)
        
        writeBody("Profile page \(id)")
        
        writeEnd()
    }
}

class FormHandler: HTTPHandler {
    override func bodyRead(requestBody: ByteBuffer) {
        if requestHead.method == .POST {
            var requestBody = requestBody
            
            if let payload = requestBody.readString(length: requestBody.readableBytes) {
                let parameters = decodeURLEncoded(string: payload)
                print(parameters)
            }
            
            redirect(to: "/")
        }
    }
}

func main() {
    Logger.level = .debug

    let staticFileRootPath = "/\(#file.split(separator: "/").dropLast().joined(separator: "/"))/public"

    let router = Router()
    router.addRule(pattern: "^/$") { _ in HomeHandler() }
    router.addRule(pattern: "^/hello$") { _ in HelloHandler() }
    router.addRule(pattern: "^/streaming$") { _ in  StreamingHandler() }
    router.addRule(pattern: "^/profiles/(.*)$") { parameters in ProfileHandler(id: parameters[0]) }
    router.addRule(pattern: "^/handle-form$") { _ in FormHandler() }
    router.fallback { _ in StaticFileHandler(rootPath: staticFileRootPath) }

    let server = HTTPServer(handler: router)
    server.bind(host: "localhost", port: 8000)
}

main()
