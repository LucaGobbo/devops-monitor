import DevopsAPI
import DevopsClient
import Foundation

extension Reviewer {
    init(_ dto: ReviewerDTO) {
        self.init(
            person: Person(id: dto.id, displayName: dto.displayName),
            vote: ReviewVote(vote: dto.vote),
            isRequired: dto.isRequired ?? false
        )
    }
}
