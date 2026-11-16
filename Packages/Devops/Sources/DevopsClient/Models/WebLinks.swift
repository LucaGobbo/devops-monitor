import Foundation

extension PullRequest {
    /// The link to open this pull request: the one the server gave, or else the standard Azure DevOps address
    /// `https://dev.azure.com/{organization}/{project}/_git/{repository}/pullrequest/{id}`.
    public func link(in organization: String) -> URL? {
        webURL ?? WebLink.url(organization, project, "_git", repository, "pullrequest", String(id))
    }
}

extension Build {
    /// The link to open this run: the one the server gave, or else the standard Azure DevOps address
    /// `https://dev.azure.com/{organization}/{project}/_build/results?buildId={id}`.
    public func link(in organization: String) -> URL? {
        webURL ?? WebLink.url(organization, project, "_build", "results", query: "buildId=\(id)")
    }
}

private enum WebLink {
    /// `https://dev.azure.com/<segments>`; nil when a segment is missing or empty.
    static func url(_ segments: String?..., query: String? = nil) -> URL? {
        let parts = segments.compactMap { $0 }.filter { !$0.isEmpty }
        guard parts.count == segments.count else { return nil }
        var components = URLComponents()
        components.scheme = "https"
        components.host = "dev.azure.com"
        components.percentEncodedPath = "/" + parts.map(encode).joined(separator: "/")
        components.percentEncodedQuery = query
        return components.url
    }

    private static func encode(_ segment: String) -> String {
        segment.addingPercentEncoding(withAllowedCharacters: .urlSegmentAllowed) ?? segment
    }
}

private extension CharacterSet {
    static let urlSegmentAllowed = CharacterSet(
        charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
    )
}
