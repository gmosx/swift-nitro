import Foundation
import NIO
import NIOHTTP1

// TODO: consider renaming to StaticFileHandler?
// TODO: support streaming / chunked
// TODO: somewhere call `try! threadPool.syncShutdownGracefully()`

//var fileIO: NonBlockingFileIO {
//    get {
//        let threadPool = BlockingIOThreadPool(numberOfThreads: 6)
//        threadPool.start()
//
//        return NonBlockingFileIO(threadPool: threadPool)
//    }
//}

public class StaticFileHandler: HTTPHandler {
    public let rootPath: String
    public let fileIO: NonBlockingFileIO

    public init(rootPath: String = "public", fileIO: NonBlockingFileIO) {
        self.rootPath = rootPath
        self.fileIO = fileIO
    }

    public override func didReceiveHead(requestHead: HTTPRequestHead) {
        //            self.keepAlive = request.isKeepAlive
        //            self.state.requestReceived()

        //            guard !requestHead.uri.containsDotDot() else {
        //                let response = httpResponseHead(request: request, status: .forbidden)
        //                ctx.write(self.wrapOutboundOut(.head(response)), promise: nil)
        //                self.completeResponse(ctx, trailers: nil, promise: nil)
        //                return
        //            }

        // TODO: test for ".."

        let path = "\(rootPath)\(requestHead.uri)"

        let fileHandleAndRegion = fileIO.openFile(path: path, eventLoop: ctx.eventLoop)

        fileHandleAndRegion.whenFailure {
            print($0)
//            sendErrorResponse(request: request, $0)
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
            self.writeEndAndClose()
            // self.completeResponse(ctx, trailers: nil, promise: p)
        }
    }
}
