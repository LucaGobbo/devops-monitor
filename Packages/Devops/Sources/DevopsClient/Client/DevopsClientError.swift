/// Errors thrown by ``DevopsClient``.
public enum DevopsClientError: Error, Sendable, Hashable {
    /// Missing, expired or insufficient credentials.
    case unauthorized
    /// The request did not reach the server.
    case network
    /// The server answered with an error status.
    case server(status: Int)
    /// The answer could not be understood.
    case invalidResponse
    /// The endpoint of ``DevopsClient/testValue`` was not overridden by the test.
    case unimplemented(String)
}
