import Foundation

// One pure function per endpoint: arguments in, `URLRequest` out.

/// `connectionData` is only served as a preview API, so it has its own api-version.
func connectionDataRequest(organization: String) throws -> URLRequest {
    try makeRequest(base: Endpoint.devOps, path: [organization, "_apis", "connectionData"], query: [], apiVersion: "7.1-preview.1")
}

func projectsRequest(organization: String, top: Int? = nil, skip: Int? = nil, apiVersion: String) throws -> URLRequest {
    try makeRequest(
        base: Endpoint.devOps,
        path: [organization, "_apis", "projects"],
        query: [("$top", top.map(String.init)), ("$skip", skip.map(String.init))],
        apiVersion: apiVersion
    )
}

func pullRequestsRequest(
    organization: String,
    project: String,
    creatorId: String? = nil,
    reviewerId: String? = nil,
    status: PullRequestStatusDTO? = .active,
    minTime: Date? = nil,
    queryTimeRange: PullRequestTimeRangeDTO? = nil,
    top: Int? = nil,
    skip: Int? = nil,
    apiVersion: String
) throws -> URLRequest {
    try makeRequest(
        base: Endpoint.devOps,
        path: [organization, project, "_apis", "git", "pullrequests"],
        query: [
            ("searchCriteria.creatorId", creatorId),
            ("searchCriteria.reviewerId", reviewerId),
            ("searchCriteria.status", status?.rawValue),
            ("searchCriteria.minTime", minTime.map(isoString)),
            ("searchCriteria.queryTimeRangeType", queryTimeRange?.rawValue),
            ("$top", top.map(String.init)),
            ("$skip", skip.map(String.init)),
        ],
        apiVersion: apiVersion
    )
}

func buildsRequest(
    organization: String,
    project: String,
    status: BuildStatusDTO? = nil,
    requestedFor: String? = nil,
    definitions: [Int]? = nil,
    queryOrder: BuildQueryOrderDTO? = nil,
    minTime: Date? = nil,
    maxTime: Date? = nil,
    top: Int? = nil,
    continuationToken: String? = nil,
    apiVersion: String
) throws -> URLRequest {
    try makeRequest(
        base: Endpoint.devOps,
        path: [organization, project, "_apis", "build", "builds"],
        query: [
            ("statusFilter", status?.rawValue),
            ("requestedFor", requestedFor),
            ("definitions", definitions.map { $0.map(String.init).joined(separator: ",") }),
            ("queryOrder", queryOrder?.rawValue),
            ("minTime", minTime.map(isoString)),
            ("maxTime", maxTime.map(isoString)),
            ("$top", top.map(String.init)),
            ("continuationToken", continuationToken),
        ],
        apiVersion: apiVersion
    )
}

/// The threads of a pull request: comments, and the system threads that record votes and reviewer changes.
/// `repository` is the repository name or id.
func pullRequestThreadsRequest(
    organization: String, project: String, repository: String, pullRequestId: Int, apiVersion: String
) throws -> URLRequest {
    try makeRequest(
        base: Endpoint.devOps,
        path: [organization, project, "_apis", "git", "repositories", repository, "pullRequests", String(pullRequestId), "threads"],
        query: [],
        apiVersion: apiVersion
    )
}

func pullRequestRequest(organization: String, project: String, id: Int, apiVersion: String) throws -> URLRequest {
    try makeRequest(
        base: Endpoint.devOps,
        path: [organization, project, "_apis", "git", "pullrequests", String(id)],
        query: [],
        apiVersion: apiVersion
    )
}

func buildRequest(organization: String, project: String, id: Int, apiVersion: String) throws -> URLRequest {
    try makeRequest(
        base: Endpoint.devOps,
        path: [organization, project, "_apis", "build", "builds", String(id)],
        query: [],
        apiVersion: apiVersion
    )
}

func timelineRequest(organization: String, project: String, buildId: Int, apiVersion: String) throws -> URLRequest {
    try makeRequest(
        base: Endpoint.devOps,
        path: [organization, project, "_apis", "build", "builds", String(buildId), "timeline"],
        query: [],
        apiVersion: apiVersion
    )
}

/// Sets `reviewerId`'s vote on a pull request. `repository` is the repository name or id.
func setVoteRequest(
    organization: String, project: String, repository: String, pullRequestId: Int,
    reviewerId: String, vote: Int, apiVersion: String
) throws -> URLRequest {
    try makeRequest(
        base: Endpoint.devOps,
        path: [organization, project, "_apis", "git", "repositories", repository, "pullRequests", String(pullRequestId), "reviewers", reviewerId],
        query: [],
        apiVersion: apiVersion,
        method: "PUT",
        body: try encodeBody(ReviewerVoteUpdateDTO(vote: vote))
    )
}

/// Updates a pull request's auto-complete: sets it (`setBy` is the user, with `mergeStrategy`) or, with
/// ``PullRequestUpdateDTO/noIdentity``, cancels it.
func setAutoCompleteRequest(
    organization: String, project: String, repository: String, pullRequestId: Int,
    update: PullRequestUpdateDTO, apiVersion: String
) throws -> URLRequest {
    try makeRequest(
        base: Endpoint.devOps,
        path: [organization, project, "_apis", "git", "repositories", repository, "pullRequests", String(pullRequestId)],
        query: [],
        apiVersion: apiVersion,
        method: "PATCH",
        body: try encodeBody(update)
    )
}

/// `2026-11-16T10:00:00Z`: the format the `minTime` / `maxTime` filters accept.
private func isoString(_ date: Date) -> String {
    date.formatted(Date.ISO8601FormatStyle())
}

private func encodeBody<T: Encodable>(_ value: T) throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    do {
        return try encoder.encode(value)
    } catch {
        throw DevopsError.invalidRequest(String(describing: error))
    }
}
