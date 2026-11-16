/// Interface for the stored Azure DevOps personal access token.
public struct AuthClient: Sendable {
    /// The stored token, or `nil` when there is none.
    public var personalAccessToken: @Sendable () async throws -> String?
    /// Stores (replaces) the token.
    public var save: @Sendable (_ personalAccessToken: String) async throws -> Void
    /// Removes the token (log out).
    public var remove: @Sendable () async throws -> Void

    public init(
        personalAccessToken: @escaping @Sendable () async throws -> String?,
        save: @escaping @Sendable (_ personalAccessToken: String) async throws -> Void,
        remove: @escaping @Sendable () async throws -> Void
    ) {
        self.personalAccessToken = personalAccessToken
        self.save = save
        self.remove = remove
    }
}

extension AuthClient {
    /// The stored token; throws ``AuthError/missingToken`` when there is none.
    public func requirePersonalAccessToken() async throws -> String {
        guard let token = try await personalAccessToken() else { throw AuthError.missingToken }
        return token
    }

    public func hasToken() async throws -> Bool {
        try await personalAccessToken() != nil
    }
}
