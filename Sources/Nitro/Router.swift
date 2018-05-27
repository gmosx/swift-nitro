import NIO

public final class Router: HTTPHandler {
    public var handlers: [String: HTTPHandler]
    public var defaultHandler: HTTPHandler

    public init(defaultHandler: HTTPHandler) {
        self.handlers = [:]
        self.defaultHandler = defaultHandler
    }
    public func route(path: String, to handler: HTTPHandler) {
        handlers[path] = handler
    }

    public override func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let requestPart = unwrapInboundIn(data)

        switch requestPart {
        case .head(let header):
            // TODO: implement proper (and efficient) routing
            for (path, handler) in handlers {
//                if header.uri.hasPrefix(path) {
                if header.uri == path {
                    handler.channelRead(ctx: ctx, data: data)
                    return
                }
            }
            defaultHandler.channelRead(ctx: ctx, data: data)

        case .body, .end:
            break
        }
    }
}
