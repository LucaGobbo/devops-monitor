import Foundation

/// The body of the pull request update that sets or cancels auto-complete.
public struct PullRequestUpdateDTO: Codable, Sendable, Hashable {
    /// The id that, as `autoCompleteSetBy`, cancels auto-complete.
    public static let noIdentity = "00000000-0000-0000-0000-000000000000"

    public var autoCompleteSetBy: IdentityDTO
    public var completionOptions: CompletionOptionsDTO?

    public init(autoCompleteSetBy: IdentityDTO, completionOptions: CompletionOptionsDTO? = nil) {
        self.autoCompleteSetBy = autoCompleteSetBy
        self.completionOptions = completionOptions
    }
}
