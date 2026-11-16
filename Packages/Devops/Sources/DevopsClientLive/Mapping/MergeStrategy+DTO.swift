import DevopsAPI
import DevopsClient

extension MergeStrategyDTO {
    init(_ strategy: MergeStrategy) {
        switch strategy {
        case .noFastForward: self = .noFastForward
        case .squash: self = .squash
        case .rebase: self = .rebase
        case .rebaseMerge: self = .rebaseMerge
        }
    }
}
