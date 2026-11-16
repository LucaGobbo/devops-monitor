extension AuthClient {
    /// Every call fails; override the closures a test needs.
    public static let testValue = AuthClient(
        personalAccessToken: { throw AuthError.missingToken },
        save: { _ in throw AuthError.missingToken },
        remove: { throw AuthError.missingToken }
    )

    /// A token that is always present and accepts every change.
    public static let previewValue = AuthClient(
        personalAccessToken: { "preview-token" },
        save: { _ in },
        remove: { }
    )
}
