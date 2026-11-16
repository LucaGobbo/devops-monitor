import Foundation

extension DevopsMiddleware {
    /// Adds the `Authorization` header to every request.
    ///
    /// Acquiring or refreshing tokens (Keychain, MSAL, ...) is the app's job: use ``auth(credential:)``
    /// and the closure is called for every request.
    public static func auth(_ credential: DevopsCredential) -> DevopsMiddleware {
        auth(credential: { credential })
    }

    /// Like ``auth(_:)``, with a credential that is resolved for every request (for tokens that expire).
    public static func auth(credential: @escaping @Sendable () async throws -> DevopsCredential) -> DevopsMiddleware {
        DevopsMiddleware { request, next in
            var request = request
            request.setValue(try await credential().headerValue, forHTTPHeaderField: "Authorization")
            return try await next(request)
        }
    }
}
