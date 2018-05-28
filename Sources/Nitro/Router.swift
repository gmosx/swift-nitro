import NIO

// TODO: add a default error handler if no default is provided

public typealias HandlerProvider = () -> HTTPHandler

/// Routes inbound requeats to handlers
///
/// This is a state-less, thread-safe handler that can be reused across channels
public final class Router: HTTPHandler {
    public var rules: [String: HandlerProvider]
    public var defaultHandlerProvider: HandlerProvider!

    public init(defaultHandler: HandlerProvider? = nil) {
        self.rules = [:]
        self.defaultHandlerProvider = defaultHandler
    }

    public func addRule(pattern: String, handler: @escaping HandlerProvider) {
        rules[pattern] = handler
    }

    public func addRule(defaultHandler: @escaping HandlerProvider) {
        self.defaultHandlerProvider = defaultHandler
    }

    public func route(uri: String) -> HTTPHandler {
        // TODO: implement proper (and efficient) routing
        for (pattern, handlerProvider) in rules {
            //                if header.uri.hasPrefix(path) {
            if uri == pattern {
                return handlerProvider()
            }
        }

        return defaultHandlerProvider()
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
