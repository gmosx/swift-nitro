import NIO

public final class Router: HTTPHandler {
    typealias InboundIn = HTTPServerRequestPart

    public var routes: [String: HTTPHandler] = [:]

    public override init() {
    }
    
    public override func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let reqPart = unwrapInboundIn(data)

        switch reqPart {
        case .head(let header):
            for (path, handler) in routes {
//                if header.uri.hasPrefix(path) {
                if header.uri == path {
                    handler.channelRead(ctx: ctx, data: data)
                }
            }

        case .body, .end:
            break
        }
    }
}
