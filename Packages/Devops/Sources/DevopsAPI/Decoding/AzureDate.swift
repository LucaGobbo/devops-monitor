import Foundation

/// Azure DevOps sends up to 7 fractional digits (`2016-11-01T16:30:31.6655471Z`), which Foundation's stock
/// ISO 8601 parsing rejects. The fraction is normalised to milliseconds before parsing.
enum AzureDate {
    static func parse(_ string: String) -> Date? {
        let normalised = string.replacing(#/\.(\d+)/#) { match in
            "." + String((match.1 + "000").prefix(3))
        }
        if let date = try? Date.ISO8601FormatStyle(includingFractionalSeconds: true).parse(normalised) {
            return date
        }
        return try? Date.ISO8601FormatStyle().parse(normalised)
    }
}
