import DevopsClient
import SwiftUI

/// One small icon per reviewer, colored by their vote.
struct ReviewerVotes: View {
    let reviewers: [Reviewer]

    var body: some View {
        HStack(spacing: 3) {
            ForEach(Array(reviewers.enumerated()), id: \.offset) { _, reviewer in
                Image(systemName: reviewer.vote.symbol)
                    .foregroundStyle(reviewer.vote.color)
                    .help("\(reviewer.person.displayName ?? "Reviewer"): \(reviewer.vote.label)")
            }
        }
    }
}

private extension ReviewVote {
    var symbol: String {
        switch self {
        case .approved, .approvedWithSuggestions: "checkmark.circle.fill"
        case .noVote: "circle.dashed"
        case .waitingForAuthor: "clock.fill"
        case .rejected: "xmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .approved: .green
        case .approvedWithSuggestions: .mint
        case .noVote: .secondary
        case .waitingForAuthor: .orange
        case .rejected: .red
        }
    }

    var label: String {
        switch self {
        case .approved: "Approved"
        case .approvedWithSuggestions: "Approved with suggestions"
        case .noVote: "No vote"
        case .waitingForAuthor: "Waiting for author"
        case .rejected: "Rejected"
        }
    }
}

#Preview {
    ReviewerVotes(reviewers: [
        Reviewer(person: Person(id: "1", displayName: "A"), vote: .approved),
        Reviewer(person: Person(id: "2", displayName: "B"), vote: .noVote),
        Reviewer(person: Person(id: "3", displayName: "C"), vote: .rejected),
    ])
    .padding()
}
