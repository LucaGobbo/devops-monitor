extension Person {
    /// Whether `threadID` is this person. Pull request threads write ids as 32 lowercase hex characters, the
    /// rest of the API as a GUID with dashes.
    public func matches(threadID: String) -> Bool {
        Self.normalized(id) == Self.normalized(threadID)
    }

    private static func normalized(_ id: String) -> String {
        id.lowercased().filter { $0 != "-" }
    }
}
