import DevopsAPI
import DevopsClient
import Foundation

extension Build {
    init(_ dto: BuildDTO) {
        self.init(
            id: dto.id,
            number: dto.buildNumber,
            state: BuildState(status: dto.status, result: dto.result),
            pipeline: dto.definition?.name,
            project: dto.project?.name,
            branch: dto.sourceBranch?.removingPrefix("refs/heads/"),
            requestedBy: (dto.requestedFor ?? dto.requestedBy).map(Person.init),
            queuedAt: dto.queueTime,
            startedAt: dto.startTime,
            finishedAt: dto.finishTime,
            webURL: dto.links?.web?.href.flatMap(URL.init(string:))
        )
    }
}
