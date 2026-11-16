import Foundation

/// The timeline of a build: every stage, phase, job and task as a flat list.
public struct TimelineDTO: Codable, Sendable, Hashable {
    public var records: [TimelineRecordDTO]

    public init(records: [TimelineRecordDTO] = []) { self.records = records }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        records = try container.decodeIfPresent([TimelineRecordDTO].self, forKey: .records) ?? []
    }

    private enum CodingKeys: String, CodingKey { case records }
}
