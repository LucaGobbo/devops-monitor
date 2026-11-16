import Foundation

/// A thread property, sent as `{ "$type": "System.String", "$value": "VoteUpdate" }`.
/// Numbers and booleans are kept as text, so callers read every property the same way.
public struct PropertyDTO: Decodable, Sendable, Hashable {
    public var type: String?
    public var value: String?

    public init(type: String? = nil, value: String? = nil) {
        self.type = type
        self.value = value
    }

    private enum CodingKeys: String, CodingKey {
        case type = "$type"
        case value = "$value"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        if let string = try? container.decodeIfPresent(String.self, forKey: .value) {
            value = string
        } else if let number = try? container.decodeIfPresent(Int.self, forKey: .value) {
            value = String(number)
        } else if let flag = try? container.decodeIfPresent(Bool.self, forKey: .value) {
            value = String(flag)
        } else {
            value = nil
        }
    }
}
