import NIO

public final class Router: HTTPHandler {
    public var handlers: [String: HTTPHandler]
    public var defaultHandler: HTTPHandler

    public init(defaultHandler: HTTPHandler) {
        self.handlers = [:]
        self.defaultHandler = defaultHandler
    }

    public func addRule(pattern: String, handler: HTTPHandler) {
        handlers[pattern] = handler
    }

    public func addRule(defaultHandler: HTTPHandler) {
        self.defaultHandler = defaultHandler
    }

    public func route(uri: String) -> HTTPHandler {
        // TODO: implement proper (and efficient) routing
        for (pattern, handler) in handlers {
            //                if header.uri.hasPrefix(path) {
            if uri == pattern {
                return handler
            }
        }

        return defaultHandler
    }

    public override func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let requestPart = unwrapInboundIn(data)

        switch requestPart {
        case .head(let requestHead):
            route(uri: requestHead.uri).channelRead(ctx: ctx, data: data)

        case .body, .end:
            break
        }
    }
}
