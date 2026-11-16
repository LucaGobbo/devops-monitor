import Foundation

/// The Azure DevOps (cloud) REST API: pull requests, builds, projects, connection data.
///
/// A plain implementation with its dependencies injected: the stable `apiVersion`, the ``DevopsMiddleware``s
/// (authentication, logging, ...) and the transport. Everything that varies per call (organization, project,
/// filters) is a function argument.
///
/// ```swift
/// let api = DevopsAPI(middlewares: [.logging(), .auth(.personalAccessToken(pat))])
/// ```
public struct DevopsAPI: Sendable {
    /// The `api-version` sent with every request.
    public let apiVersion: String
    private let middlewares: [DevopsMiddleware]
    private let transport: DevopsTransport

    /// - Parameters:
    ///   - apiVersion: the `api-version` sent with every request.
    ///   - middlewares: applied in order, the first one is the outermost. Recommended: `[.logging(), .auth(...)]`.
    ///   - transport: performs the request; defaults to `URLSession.shared`.
    public init(
        apiVersion: String = "7.1",
        middlewares: [DevopsMiddleware] = [],
        transport: @escaping DevopsTransport = DevopsAPI.urlSessionTransport
    ) {
        self.apiVersion = apiVersion
        self.middlewares = middlewares
        self.transport = transport
    }

    /// The organization's connection data; `authenticatedUser.id` is the id to use as `creatorId` / `reviewerId` /
    /// `requestedFor`. Needs no scope beyond the ones of the other calls.
    public func connectionData(organization: String) async throws -> ConnectionDataDTO {
        let request = try connectionDataRequest(organization: organization)
        return try decode(ConnectionDataDTO.self, from: try await send(request).data)
    }

    /// Projects of an organization.
    public func projects(organization: String, top: Int? = nil, skip: Int? = nil) async throws -> [ProjectDTO] {
        let request = try projectsRequest(organization: organization, top: top, skip: skip, apiVersion: apiVersion)
        return try decode(ListResponseDTO<ProjectDTO>.self, from: try await send(request).data).value
    }

    /// Pull requests of a project.
    ///
    /// - Parameters:
    ///   - creatorId: only pull requests created by this identity id.
    ///   - reviewerId: only pull requests where this identity id is a reviewer. Pull requests have no assignee;
    ///     "assigned to me" means "reviewer". Reviews requested from a team the user belongs to are not matched.
    ///   - status: defaults to `.active`; pass `nil` to use the server default (also active).
    ///   - minTime: only pull requests created or closed (see `queryTimeRange`) at or after this time.
    ///   - queryTimeRange: which date `minTime` applies to; the server defaults to the creation date.
    public func pullRequests(
        organization: String,
        project: String,
        creatorId: String? = nil,
        reviewerId: String? = nil,
        status: PullRequestStatusDTO? = .active,
        minTime: Date? = nil,
        queryTimeRange: PullRequestTimeRangeDTO? = nil,
        top: Int? = nil,
        skip: Int? = nil
    ) async throws -> [PullRequestDTO] {
        let request = try pullRequestsRequest(
            organization: organization, project: project, creatorId: creatorId, reviewerId: reviewerId,
            status: status, minTime: minTime, queryTimeRange: queryTimeRange, top: top, skip: skip, apiVersion: apiVersion
        )
        return try decode(ListResponseDTO<PullRequestDTO>.self, from: try await send(request).data).value
    }

    /// One pull request, whatever its status.
    public func pullRequest(organization: String, project: String, id: Int) async throws -> PullRequestDTO {
        let request = try pullRequestRequest(organization: organization, project: project, id: id, apiVersion: apiVersion)
        return try decode(PullRequestDTO.self, from: try await send(request).data)
    }

    /// The threads of a pull request. Besides comments they hold system threads that record votes
    /// (`CodeReviewThreadType = VoteUpdate`) and reviewer changes (`ReviewersUpdate`).
    /// - Parameter repository: the repository name or id.
    public func pullRequestThreads(
        organization: String, project: String, repository: String, pullRequestId: Int
    ) async throws -> [PullRequestThreadDTO] {
        let request = try pullRequestThreadsRequest(
            organization: organization, project: project, repository: repository, pullRequestId: pullRequestId,
            apiVersion: apiVersion
        )
        return try decode(ListResponseDTO<PullRequestThreadDTO>.self, from: try await send(request).data).value
    }

    /// Sets `reviewerId`'s vote on a pull request (10 approved, 5 approved with suggestions, 0 no vote,
    /// -5 waiting for author, -10 rejected). Needs a token with the Code (Read & Write) scope.
    /// - Parameter repository: the repository name or id.
    public func setVote(
        organization: String, project: String, repository: String, pullRequestId: Int, reviewerId: String, vote: Int
    ) async throws {
        let request = try setVoteRequest(
            organization: organization, project: project, repository: repository, pullRequestId: pullRequestId,
            reviewerId: reviewerId, vote: vote, apiVersion: apiVersion
        )
        _ = try await send(request)
    }

    /// Sets auto-complete on a pull request: it completes with `mergeStrategy` once its policies pass.
    /// Needs a token with the Code (Read & Write) scope.
    /// - Parameters:
    ///   - repository: the repository name or id.
    ///   - setBy: the identity id of the user setting it.
    public func setAutoComplete(
        organization: String, project: String, repository: String, pullRequestId: Int,
        setBy: String, mergeStrategy: MergeStrategyDTO
    ) async throws {
        try await updatePullRequest(
            organization: organization, project: project, repository: repository, pullRequestId: pullRequestId,
            update: PullRequestUpdateDTO(autoCompleteSetBy: IdentityDTO(id: setBy), completionOptions: CompletionOptionsDTO(mergeStrategy: mergeStrategy))
        )
    }

    /// Cancels auto-complete on a pull request.
    /// - Parameter repository: the repository name or id.
    public func cancelAutoComplete(
        organization: String, project: String, repository: String, pullRequestId: Int
    ) async throws {
        try await updatePullRequest(
            organization: organization, project: project, repository: repository, pullRequestId: pullRequestId,
            update: PullRequestUpdateDTO(autoCompleteSetBy: IdentityDTO(id: PullRequestUpdateDTO.noIdentity))
        )
    }

    private func updatePullRequest(
        organization: String, project: String, repository: String, pullRequestId: Int, update: PullRequestUpdateDTO
    ) async throws {
        let request = try setAutoCompleteRequest(
            organization: organization, project: project, repository: repository, pullRequestId: pullRequestId,
            update: update, apiVersion: apiVersion
        )
        _ = try await send(request)
    }

    /// One build (pipeline run), whatever its status.
    public func build(organization: String, project: String, id: Int) async throws -> BuildDTO {
        let request = try buildRequest(organization: organization, project: project, id: id, apiVersion: apiVersion)
        return try decode(BuildDTO.self, from: try await send(request).data)
    }

    /// The stages, phases, jobs and tasks of a build, as a flat list. A build that has not started has none.
    public func timeline(organization: String, project: String, buildId: Int) async throws -> TimelineDTO {
        let request = try timelineRequest(organization: organization, project: project, buildId: buildId, apiVersion: apiVersion)
        return try decode(TimelineDTO.self, from: try await send(request).data)
    }

    /// Builds (pipeline runs) of a project, as a page. Pass the returned `continuationToken` to get the next page.
    ///
    /// The server accepts a single `status`; to get `inProgress` and `notStarted` builds make two calls.
    /// - Parameters:
    ///   - requestedFor: identity id (or name) the build was requested for.
    ///   - definitions: only builds of these pipeline definition ids.
    ///   - minTime, maxTime: only builds whose time is in range; the time is the one `queryOrder` names
    ///     (queue time by default).
    public func builds(
        organization: String,
        project: String,
        status: BuildStatusDTO? = nil,
        requestedFor: String? = nil,
        definitions: [Int]? = nil,
        queryOrder: BuildQueryOrderDTO? = nil,
        minTime: Date? = nil,
        maxTime: Date? = nil,
        top: Int? = nil,
        continuationToken: String? = nil
    ) async throws -> PageDTO<BuildDTO> {
        let request = try buildsRequest(
            organization: organization, project: project, status: status, requestedFor: requestedFor,
            definitions: definitions, queryOrder: queryOrder, minTime: minTime, maxTime: maxTime, top: top,
            continuationToken: continuationToken, apiVersion: apiVersion
        )
        let (data, response) = try await send(request)
        return PageDTO(
            items: try decode(ListResponseDTO<BuildDTO>.self, from: data).value,
            continuationToken: responseContinuationToken(in: response)
        )
    }

    private func send(_ request: URLRequest) async throws -> (data: Data, response: HTTPURLResponse) {
        try await sendThroughMiddlewares(request, middlewares: middlewares, transport: transport)
    }
}
