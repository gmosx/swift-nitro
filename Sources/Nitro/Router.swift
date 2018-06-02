import NIO
import Logging

// TODO: add a default error handler if no default is provided

public typealias HandlerProvider = () -> HTTPHandler

/// Routes inbound requeats to handlers
public final class Router: HTTPHandler {
    public var rules: [String: HandlerProvider]
    public var fallbackHandlerProvider: HandlerProvider?
    private var handler: HTTPHandler?

    public override init() {
        self.rules = [:]
    }

    public func addRule(pattern: String, handlerProvider: @escaping HandlerProvider) {
        rules[pattern] = handlerProvider
    }

    public func fallback(handlerProvider: @escaping HandlerProvider) {
        self.fallbackHandlerProvider = handlerProvider
    }

    public func route(uri: String) -> HTTPHandler? {
        // TODO: implement proper (and efficient) routing
        let path = uri.split(separator: "?").first!

        for (pattern, handlerProvider) in rules {
            //                if header.uri.hasPrefix(path) {
            if path == pattern {
                return handlerProvider()
            }
        }

        return fallbackHandlerProvider?()
    }

    public override func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let requestPart = unwrapInboundIn(data)

        switch requestPart {
        case .head(let requestHead):
            Logger.debug("Routing \(requestHead.uri)")
            handler = route(uri: requestHead.uri)

        case .body, .end:
            break
        }

        if let handler = handler {
            handler.channelRead(ctx: ctx, data: data)
        } else {
            Logger.info("No handler found for \(requestHead.uri)")
        }
    }
}
