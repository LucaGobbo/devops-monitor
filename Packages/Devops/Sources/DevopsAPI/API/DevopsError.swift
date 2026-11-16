import Foundation

/// Errors thrown by ``DevopsAPI``.
public enum DevopsError: Error, Sendable, Equatable {
    /// The server answered with a non-success status. `body` is a short snippet of the response body.
    ///
    /// Azure DevOps answers an unauthenticated request with `203` and an HTML sign-in page, which is reported
    /// here too (instead of failing later with a confusing decoding error).
    case http(status: Int, body: String)
    /// The response body could not be decoded into the expected DTO.
    case decoding(String)
    /// The underlying transport request failed.
    case transport(URLError)
    /// The request URL could not be built.
    case invalidRequest(String)
    /// The transport returned something that is not an HTTP response.
    case invalidResponse
    /// The called endpoint of ``DevopsAPI/testValue`` was not overridden by the test.
    case unimplemented(String)
}
