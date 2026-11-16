import Foundation

public enum AuthError: Error, Sendable, Equatable {
    /// No personal access token is stored yet.
    case missingToken
    /// The token is empty.
    case invalidToken
    /// A keychain call failed with this status.
    case keychain(OSStatus)
}
