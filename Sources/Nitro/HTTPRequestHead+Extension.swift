extension HTTPRequestHead {
    public var queryString: String? {
        if let queryString = uri.split(separator: "?").last {
            return String(queryString)
        } else {
            return nil
        }
    }
}
