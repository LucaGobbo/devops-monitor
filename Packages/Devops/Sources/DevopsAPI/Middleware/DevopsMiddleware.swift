import Foundation

/// Intercepts every request made by the live ``DevopsAPI``.
///
/// A middleware can modify the request before calling `next`, inspect or replace the response, or short-circuit by
/// not calling `next`. Middlewares are applied in array order: the first element is the outermost one. Recommended
/// order: `[.logging(), .auth(...)]`, so logs see requests before credentials are attached.
public struct DevopsMiddleware: Sendable {
    /// The rest of the chain; the last link performs the actual transport.
    public typealias Next = @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)

    public var intercept: @Sendable (_ request: URLRequest, _ next: Next) async throws -> (Data, HTTPURLResponse)

    public init(intercept: @escaping @Sendable (_ request: URLRequest, _ next: Next) async throws -> (Data, HTTPURLResponse)) {
        self.intercept = intercept
    }
}
