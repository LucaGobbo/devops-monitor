import DevopsAPI
import DevopsClient

extension DevopsClient {
    /// The real implementation on top of ``DevopsAPI``.
    ///
    /// ```swift
    /// DevopsClient.live(api: DevopsAPI(middlewares: [.logging(), .auth(.personalAccessToken(pat))]))
    /// ```
    /// Every call lists the organization's projects, then queries them concurrently.
    /// Builds are not paged (the newest 100 queued and 100 running builds per project are returned).
    public static func live(api: DevopsAPI = DevopsAPI()) -> DevopsClient {
        DevopsClient(
            currentUser: { organization in
                try await mapErrors { Person(try await api.connectionData(organization: organization).authenticatedUser) }
            },
            pullRequests: { organization, involvement, me in
                try await mapErrors {
                    return try await forEachProject(in: organization, api: api) { project in
                        try await api.pullRequests(
                            organization: organization,
                            project: project,
                            creatorId: involvement == .createdByMe ? me.id : nil,
                            reviewerId: involvement == .assignedToMe ? me.id : nil
                        ).map(PullRequest.init)
                    }
                }
            },
            recentPullRequests: { organization, involvement, me, since in
                try await mapErrors {
                    return try await forEachProject(in: organization, api: api) { project in
                        // The time filter applies to one date, so "created since" and "closed since" are two requests.
                        var pullRequests: [PullRequestDTO] = []
                        for range in [PullRequestTimeRangeDTO.created, .closed] {
                            pullRequests += try await api.pullRequests(
                                organization: organization,
                                project: project,
                                creatorId: involvement == .createdByMe ? me.id : nil,
                                reviewerId: involvement == .assignedToMe ? me.id : nil,
                                status: .all,
                                minTime: since,
                                queryTimeRange: range,
                                top: 200
                            )
                        }
                        var seen = Set<Int>()
                        return pullRequests.filter { seen.insert($0.pullRequestId).inserted }.map(PullRequest.init)
                    }
                }
            },
            recentBuilds: { organization, me, since in
                try await mapErrors {
                    return try await forEachProject(in: organization, api: api) { project in
                        var builds: [Build] = []
                        var token: String?
                        // Newest first, so the pages that matter come first; the cap keeps a busy project bounded.
                        for _ in 0..<10 {
                            let page = try await api.builds(
                                organization: organization, project: project, status: .all, requestedFor: me.id,
                                queryOrder: .queueTimeDescending, minTime: since, top: 200, continuationToken: token
                            )
                            builds += page.items.map(Build.init)
                            token = page.continuationToken
                            if token == nil { break }
                        }
                        return builds
                    }
                }
            },
            pullRequestEvents: { organization, pullRequest in
                let location = try pullRequest.location()
                return try await mapErrors {
                    try await api.pullRequestThreads(
                        organization: organization, project: location.project, repository: location.repository,
                        pullRequestId: pullRequest.id
                    ).compactMap(PullRequestEvent.init)
                }
            },
            activeBuilds: { organization, me in
                try await mapErrors {
                    return try await forEachProject(in: organization, api: api) { project in
                        // The server accepts a single status filter, so running and queued builds are two requests.
                        var builds: [Build] = []
                        for status in [BuildStatusDTO.inProgress, .notStarted] {
                            builds += try await api.builds(
                                organization: organization, project: project, status: status, requestedFor: me.id, top: 100
                            ).items.map(Build.init)
                        }
                        return builds
                    }
                }
            },
            pullRequest: { organization, project, id in
                try await mapErrors { PullRequest(try await api.pullRequest(organization: organization, project: project, id: id)) }
            },
            build: { organization, project, id in
                try await mapErrors { Build(try await api.build(organization: organization, project: project, id: id)) }
            },
            timeline: { organization, project, buildId in
                try await mapErrors {
                    do {
                        return BuildTimeline(try await api.timeline(organization: organization, project: project, buildId: buildId))
                    } catch DevopsError.http(let status, _) where status == 404 {
                        return BuildTimeline() // a run that has not started has no timeline yet
                    }
                }
            },
            vote: { organization, pullRequest, vote, me in
                let location = try pullRequest.location()
                try await mapErrors {
                    try await api.setVote(
                        organization: organization, project: location.project, repository: location.repository,
                        pullRequestId: pullRequest.id, reviewerId: me.id, vote: vote.value
                    )
                }
            },
            setAutoComplete: { organization, pullRequest, strategy, me in
                let location = try pullRequest.location()
                try await mapErrors {
                    try await api.setAutoComplete(
                        organization: organization, project: location.project, repository: location.repository,
                        pullRequestId: pullRequest.id, setBy: me.id, mergeStrategy: MergeStrategyDTO(strategy)
                    )
                }
            },
            cancelAutoComplete: { organization, pullRequest in
                let location = try pullRequest.location()
                try await mapErrors {
                    try await api.cancelAutoComplete(
                        organization: organization, project: location.project, repository: location.repository,
                        pullRequestId: pullRequest.id
                    )
                }
            }
        )
    }
}

private extension PullRequest {
    /// Where to address the pull request; a pull request the server sent without them cannot be updated.
    func location() throws -> (project: String, repository: String) {
        guard let project, let repository else { throw DevopsClientError.invalidResponse }
        return (project, repository)
    }
}

/// Runs `work` for every project of the organization concurrently and concatenates the results.
private func forEachProject<T: Sendable>(
    in organization: String,
    api: DevopsAPI,
    _ work: @escaping @Sendable (_ project: String) async throws -> [T]
) async throws -> [T] {
    let projects = try await api.projects(organization: organization)
    return try await withThrowingTaskGroup(of: [T].self) { group in
        for name in projects.compactMap(\.name) {
            group.addTask { try await work(name) }
        }
        return try await group.reduce(into: []) { $0 += $1 }
    }
}

/// Runs `work` and translates ``DevopsError`` into ``DevopsClientError``.
private func mapErrors<T>(_ work: () async throws -> T) async throws -> T {
    do {
        return try await work()
    } catch let error as DevopsError {
        throw DevopsClientError(error)
    }
}
