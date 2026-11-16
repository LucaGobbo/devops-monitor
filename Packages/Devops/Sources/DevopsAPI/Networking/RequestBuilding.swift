import Foundation

/// Builds `base/<path segments>?<query>&api-version=...` as a request (GET unless `method` says otherwise, with an
/// optional JSON `body`). Nil query values are skipped; everything is percent-encoded strictly (so e.g. `+` in a
/// continuation token cannot be misread as a space).
func makeRequest(
    base: URL,
    path: [String],
    query: [(name: String, value: String?)],
    apiVersion: String,
    method: String = "GET",
    body: Data? = nil
) throws -> URLRequest {
    var components = URLComponents(url: base, resolvingAgainstBaseURL: false)
    components?.percentEncodedPath = "/" + path.map { $0.percentEncoded() }.joined(separator: "/")
    components?.percentEncodedQuery = (query + [("api-version", apiVersion)])
        .compactMap { name, value in
            value.map { "\(name.percentEncoded().replacing("%24", with: "$"))=\($0.percentEncoded())" }
        }
        .joined(separator: "&")
    guard let url = components?.url else {
        throw DevopsError.invalidRequest("Cannot build URL for path \(path)")
    }
    var request = URLRequest(url: url)
    request.httpMethod = method
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    if let body {
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    return request
}

private extension String {
    /// Percent-encodes everything except RFC 3986 unreserved characters.
    func percentEncoded() -> String {
        addingPercentEncoding(withAllowedCharacters: .devopsUnreserved) ?? self
    }
}

private extension CharacterSet {
    static let devopsUnreserved = CharacterSet(
        charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
    )
}
