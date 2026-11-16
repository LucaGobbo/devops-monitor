import Foundation

/// One node of a build timeline: a stage, phase, job or task. Nesting is expressed through `parentId`.
public struct TimelineRecordDTO: Codable, Sendable, Hashable {
    public var id: String
    public var parentId: String?
    public var type: TimelineRecordTypeDTO?
    public var name: String?
    public var order: Int?
    public var state: TimelineRecordStateDTO?
    public var result: TimelineRecordResultDTO?
    public var startTime: Date?
    public var finishTime: Date?

    public init(
        id: String, parentId: String? = nil, type: TimelineRecordTypeDTO? = nil, name: String? = nil, order: Int? = nil,
        state: TimelineRecordStateDTO? = nil, result: TimelineRecordResultDTO? = nil,
        startTime: Date? = nil, finishTime: Date? = nil
    ) {
        self.id = id
        self.parentId = parentId
        self.type = type
        self.name = name
        self.order = order
        self.state = state
        self.result = result
        self.startTime = startTime
        self.finishTime = finishTime
    }
}
