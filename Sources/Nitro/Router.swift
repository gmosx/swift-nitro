import NIO

public final class Router: HTTPHandler {
    public var routes: [String: HTTPHandler] = [:]

    public func route(path: String, to handler: HTTPHandler) {
        routes[path] = handler
    }

    public override func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let requestPart = unwrapInboundIn(data)

        switch requestPart {
        case .head(let header):
            // TODO: implement proper (and efficient) routing
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
