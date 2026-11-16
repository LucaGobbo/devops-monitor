import Foundation

/// A credential for the `Authorization` header.
public enum DevopsCredential: Sendable, Equatable {
    /// Azure DevOps personal access token, sent as `Basic base64(":" + token)`.
    case personalAccessToken(String)
    /// Microsoft Entra ID access token, sent as `Bearer <token>`.
    case bearer(String)

    var headerValue: String {
        switch self {
        case .personalAccessToken(let token):
            "Basic " + Data(":\(token)".utf8).base64EncodedString()
        case .bearer(let token):
            "Bearer " + token
        }
    }
}
