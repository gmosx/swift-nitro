import Foundation
import NIO
import NIOHTTP1

//// TODO: somewhere call `try! threadPool.syncShutdownGracefully()`
//var fileIO: NonBlockingFileIO {
//    get {
//        let threadPool = BlockingIOThreadPool(numberOfThreads: 6)
//        threadPool.start()
//
//        return NonBlockingFileIO(threadPool: threadPool)
//    }
//}

public class FileHandler: HTTPHandler {
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
            var responseHead = HTTPResponseHead(version: requestHead.version, status: .ok)
            responseHead.headers.add(name: "Content-Length", value: "\(region.endIndex)")
            responseHead.headers.add(name: "Content-Type", value: mimeType(path: path))
            self.ctx.write(self.wrapOutboundOut(.head(responseHead)), promise: nil)
            self.ctx.writeAndFlush(self.wrapOutboundOut(.body(.fileRegion(region)))).then {
                let p: EventLoopPromise<Void> = self.ctx.eventLoop.newPromise()
                self.ctx.writeAndFlush(self.wrapOutboundOut(.end(/*trailers*/nil)), promise: p)
//                self.completeResponse(ctx, trailers: nil, promise: p)
                return p.futureResult
                }.thenIfError { (_: Error) in
                    self.ctx.close()
                }.whenComplete {
                    _ = try? file.close()
            }
        }
    }
}
