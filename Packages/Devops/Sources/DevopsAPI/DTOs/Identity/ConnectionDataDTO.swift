import Foundation

/// The organization's `connectionData`; only the authenticated user is modelled.
public struct ConnectionDataDTO: Codable, Sendable, Hashable {
    public var authenticatedUser: AuthenticatedUserDTO

    public init(authenticatedUser: AuthenticatedUserDTO) { self.authenticatedUser = authenticatedUser }

    public struct AuthenticatedUserDTO: Codable, Sendable, Hashable {
        public var id: String
        public var providerDisplayName: String?

        public init(id: String, providerDisplayName: String? = nil) {
            self.id = id
            self.providerDisplayName = providerDisplayName
        }
    }
}
