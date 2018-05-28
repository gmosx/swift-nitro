import Foundation
import NIO
import NIOHTTP1

// TODO: support streaming / chunked

public class StaticFileHandler: HTTPHandler {
    public let rootPath: String

    public init(rootPath: String = "public") {
        self.rootPath = rootPath
    }

    public override func didReceiveHead(requestHead: HTTPRequestHead) {
        guard requestHead.uri.range(of: "..") == nil else {
            self.writeHead(status: .forbidden)
            self.writeEnd()
            return
        }

        let path = "\(rootPath)\(requestHead.uri)"

        // TODO: ultra-hack, we use the fileIO initialized in HTTPServer!
        let fileHandleAndRegion = fileIO.openFile(path: path, eventLoop: ctx.eventLoop)

        fileHandleAndRegion.whenFailure { error in
            var body = self.ctx.channel.allocator.buffer(capacity: 128)

            switch error {
            case let e as IOError where e.errnoCode == ENOENT:
                body.write(staticString: "IOError (not found)\r\n")
                self.writeHead(status: .notFound)

            case let e as IOError:
                body.write(staticString: "IOError (other)\r\n")
                body.write(string: e.description)
                body.write(staticString: "\r\n")
                self.writeHead(status: .notFound)

            default:
                body.write(string: "\(type(of: error)) error\r\n")
                self.writeHead(status: .internalServerError)
            }

            self.writeBody(body)
            self.writeEnd()
        }

        fileHandleAndRegion.whenSuccess { (file, region) in
            defer {
                _ = try? file.close()
            }

            var responseHeaders = HTTPHeaders()
            responseHeaders.add(name: "Content-Length", value: "\(region.endIndex)")
            responseHeaders.add(name: "Content-Type", value: mimeType(path: path))

            self.writeHead(status: .ok, headers: responseHeaders)
            self.writeBody(region)
            self.writeEnd()
        }
    }
}
