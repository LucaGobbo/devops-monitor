import AuthClient

extension AuthClient {
    /// Keychain-backed implementation; the keychain is read at most once.
    public static func live(service: String = "Devops-monitor", account: String = "azure-devops-personal-access-token") -> AuthClient {
        let provider = AuthProvider(service: service, account: account)
        return AuthClient(
            personalAccessToken: { try await provider.personalAccessToken() },
            save: { try await provider.save(personalAccessToken: $0) },
            remove: { try await provider.removePersonalAccessToken() }
        )
    }
}
