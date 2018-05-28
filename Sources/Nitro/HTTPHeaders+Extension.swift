import NIO

extension HTTPHeaders {
    public func cookie(named name: String) -> String? {
        // TODO: more effient implementation is needed!
        if contains(name: "Cookie") {
            let cookies = self["Cookie"].first!.split(separator: ";")
            for cookie in cookies {
                if cookie.replacingOccurrences(of: " ", with: "").hasPrefix("\(name)=") {
                    return String(cookie.split(separator: "=").last!)
                }
            }
        }

        return nil
    }

    public mutating func addCookie(name: String, value: String, domain: String? = nil, path: String? = nil, httpOnly: Bool? = nil, secure: Bool? = nil, maxAge: Int? = nil) {
        var builder: [String] = ["\(name)=\(value)"]

        if let domain = domain {
            builder.append("Domain=\(domain)")
        }

        if let path = path {
            builder.append("Path=\(path)")
        }

        if let httpOnly = httpOnly {
            builder.append("HttpOnly=\(httpOnly)")
        }

        if let secure = secure {
            builder.append("Secure=\(secure)")
        }

        if let maxAge = maxAge {
            builder.append("Max-Age=\(maxAge)")
        }

        add(name: "Set-Cookie", value: builder.joined(separator: "; "))
    }

    public mutating func removeCookie(named name: String, domain: String? = nil, path: String? = nil) {
        addCookie(name: name, value: "", domain: domain, path: path, maxAge: 0)
    }
}
