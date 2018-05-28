import NIO

// TODO: add a default error handler if no default is provided

public typealias HandlerProvider = () -> HTTPHandler

/// Routes inbound requeats to handlers
///
/// This is a state-less, thread-safe handler that can be reused across channels
public final class Router: HTTPHandler {
    public var rules: [String: HandlerProvider]
    public var fallbackHandlerProvider: HandlerProvider!

    public override init() {
        self.rules = [:]
    }

    public func addRule(pattern: String, handlerProvider: @escaping HandlerProvider) {
        rules[pattern] = handlerProvider
    }

    public func addFallbackRule(handlerProvider: @escaping HandlerProvider) {
        self.fallbackHandlerProvider = handlerProvider
    }

    public func route(uri: String) -> HTTPHandler {
        // TODO: implement proper (and efficient) routing
        for (pattern, handlerProvider) in rules {
            //                if header.uri.hasPrefix(path) {
            if uri == pattern {
                return handlerProvider()
            }
        }

        return fallbackHandlerProvider()
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
