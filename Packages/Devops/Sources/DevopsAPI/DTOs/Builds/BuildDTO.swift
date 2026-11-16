import Foundation

public struct BuildDTO: Codable, Sendable, Hashable {
    public var id: Int
    public var buildNumber: String?
    public var status: BuildStatusDTO?
    public var result: BuildResultDTO?
    public var reason: String?
    public var queueTime: Date?
    public var startTime: Date?
    public var finishTime: Date?
    public var sourceBranch: String?
    public var sourceVersion: String?
    public var definition: BuildDefinitionRefDTO?
    public var project: ProjectRefDTO?
    public var requestedFor: IdentityDTO?
    public var requestedBy: IdentityDTO?
    public var url: String?
    public var links: BuildLinksDTO?

    public init(id: Int, buildNumber: String? = nil, status: BuildStatusDTO? = nil, result: BuildResultDTO? = nil,
                reason: String? = nil, queueTime: Date? = nil, startTime: Date? = nil, finishTime: Date? = nil,
                sourceBranch: String? = nil, sourceVersion: String? = nil, definition: BuildDefinitionRefDTO? = nil,
                project: ProjectRefDTO? = nil, requestedFor: IdentityDTO? = nil, requestedBy: IdentityDTO? = nil,
                url: String? = nil, links: BuildLinksDTO? = nil) {
        self.id = id
        self.buildNumber = buildNumber
        self.status = status
        self.result = result
        self.reason = reason
        self.queueTime = queueTime
        self.startTime = startTime
        self.finishTime = finishTime
        self.sourceBranch = sourceBranch
        self.sourceVersion = sourceVersion
        self.definition = definition
        self.project = project
        self.requestedFor = requestedFor
        self.requestedBy = requestedBy
        self.url = url
        self.links = links
    }

    private enum CodingKeys: String, CodingKey {
        case id, buildNumber, status, result, reason, queueTime, startTime, finishTime, sourceBranch
        case sourceVersion, definition, project, requestedFor, requestedBy, url
        case links = "_links"
    }
}
