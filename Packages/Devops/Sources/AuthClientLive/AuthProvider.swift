import AuthClient
import Foundation

/// Owns the Azure DevOps personal access token: persisted in the keychain, read from it at most once and
/// served from memory afterwards.
actor AuthProvider {
    private enum Cache {
        case notLoaded
        /// Loaded from the keychain (or written by us); `nil` means there is no token.
        case loaded(String?)
    }

    private let keychain: Keychain
    private var cache = Cache.notLoaded

    init(service: String = "Devops-monitor", account: String = "azure-devops-personal-access-token") {
        keychain = Keychain(service: service, account: account)
    }

    /// The stored token, or `nil` when there is none. Only the first call touches the keychain.
    func personalAccessToken() throws -> String? {
        if case .loaded(let token) = cache { return token }
        let token = try keychain.read()
        cache = .loaded(token)
        return token
    }

    /// The stored token; throws ``AuthError/missingToken`` when there is none.
    func requirePersonalAccessToken() throws -> String {
        guard let token = try personalAccessToken() else { throw AuthError.missingToken }
        return token
    }

    var hasToken: Bool {
        get throws { try personalAccessToken() != nil }
    }

    /// Stores the token in the keychain (replacing an existing one) and in the cache.
    func save(personalAccessToken token: String) throws {
        let token = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !token.isEmpty else { throw AuthError.invalidToken }
        try keychain.write(token)
        cache = .loaded(token)
    }

    /// Removes the token from the keychain and the cache (log out).
    func removePersonalAccessToken() throws {
        try keychain.delete()
        cache = .loaded(nil)
    }
}
