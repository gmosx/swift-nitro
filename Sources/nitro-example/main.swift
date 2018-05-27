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
        writeBody("Hello World! YEAH! <a href=\"/\">Home</a><img src=\"reizu-mark.svg\" />")
        writeEndAndClose()
    }
}

// TODO: hide the threadPool / fileIO creation in the framework.
let threadPool = BlockingIOThreadPool(numberOfThreads: 6)
threadPool.start()
let fileIO = NonBlockingFileIO(threadPool: threadPool)

let rootPath = "/\(#file.split(separator: "/").dropLast().joined(separator: "/"))/public"
let fileHandler = FileHandler(rootPath: rootPath, fileIO: fileIO)

let router = Router(defaultHandler: fileHandler)
router.addRule(pattern: "/", handler: HomeHandler())
router.addRule(pattern: "/hello", handler: HelloHandler())

let server = HTTPServer(handler: router)
server.bind(host: "localhost", port: 1337)
