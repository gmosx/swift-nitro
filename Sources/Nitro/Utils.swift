
public func decodeURLEncoded(string: String) -> [String: [String]] {
    var values: [String: [String]] = [:]

    for pair in string.split(separator: "&") {
        let splitPair = pair.split(separator: "=", maxSplits: 1,
                                   omittingEmptySubsequences: false)
            .map { $0.replacingOccurrences(of: "+", with: " ") }
            .map { $0.removingPercentEncoding ?? "??" } // TODO
        let name  = splitPair[0]
        let value = splitPair.count > 1 ? splitPair[1] : nil

        if let value = value {
            if values[name]?.append(value) == nil {
                values[name] = [ value ]
            }
        } else if values[name] == nil {
            values[name] = []
        }
    }

    return values
}
