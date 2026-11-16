import DevopsAPI
import DevopsClient
import Foundation

extension BuildState {
    init(status: BuildStatusDTO?, result: BuildResultDTO?) {
        if status == .inProgress || status == .cancelling {
            self = .inProgress
        } else if status == .notStarted || status == .postponed {
            self = .notStarted
        } else if status == .completed {
            switch result {
            case .succeeded: self = .succeeded
            case .partiallySucceeded: self = .partiallySucceeded
            case .failed: self = .failed
            case .canceled: self = .canceled
            default: self = .unknown
            }
        } else {
            self = .unknown
        }
    }
}
