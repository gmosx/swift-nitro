import NIO

// TODO: add a default error handler if no default is provided

/// Routes inbound requeats to handlers
///
/// This is a state-less, thread-safe handler that can be reused across channels
public final class Router: HTTPHandler {
    public var rules: [String: HTTPHandler]
    public var defaultHandler: HTTPHandler!

    public init(defaultHandler: HTTPHandler? = nil) {
        self.rules = [:]
        self.defaultHandler = defaultHandler
    }

    public func addRule(pattern: String, handler: HTTPHandler) {
        rules[pattern] = handler
    }

    public func addRule(defaultHandler: HTTPHandler) {
        self.defaultHandler = defaultHandler
    }

    public func route(uri: String) -> HTTPHandler {
        // TODO: implement proper (and efficient) routing
        for (pattern, handler) in rules {
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
