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

    public mutating func addCookie(name: String, value: String, httpOnly: Bool = true, secure: Bool? = nil, maxAge: Int? = nil) {
        // TODO: handle extra options
        add(name: "Set-Cookie", value: "\(name)=\(value)")
    }

    public mutating func removeCookie(named name: String) {
        // TODO: handle path, domain
        replaceOrAdd(name: "Set-Cookie", value: "\(name)=; Max-Age=0")
    }
}
