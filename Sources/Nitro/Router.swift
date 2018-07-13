import NIO
import Logging
import RegExp

// TODO: Rename to URIRouter or URLRouter or something.
// TODO: add a default error handler if no default is provided

public typealias HandlerProvider = (_ parameters: [String]) -> HTTPHandler

/// Routes inbound requeats to handlers
public final class Router: HTTPHandler {
    public var rules: [(RegExp, HandlerProvider)]
    public var fallbackHandlerProvider: HandlerProvider?
    private var handler: HTTPHandler?

    public override init() {
        self.rules = []
    }

    public func addRule(pattern: String, handlerProvider: @escaping HandlerProvider) {
        rules.append((RegExp(pattern), handlerProvider))
    }

    public func fallback(handlerProvider: @escaping HandlerProvider) {
        self.fallbackHandlerProvider = handlerProvider
    }

    // TODO: implement proper (and efficient) routing
    public func route(uri: String) -> HTTPHandler? {
        let path = String(uri.split(separator: "?").first!)

        for (pattern, handlerProvider) in rules {
            if path =~ pattern {
                if let match = pattern.matches(in: path).first {
                    let parameters = match.ranges.dropFirst().map { String(path[$0]) }
                    return handlerProvider(parameters)
                }
            }
        }

        return fallbackHandlerProvider?([])
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
