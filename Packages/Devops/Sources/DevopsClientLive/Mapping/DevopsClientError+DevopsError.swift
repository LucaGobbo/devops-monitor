import DevopsAPI
import DevopsClient
import Foundation

extension DevopsClientError {
    init(_ error: DevopsError) {
        switch error {
        case .http(let status, _) where [401, 403, 203].contains(status): self = .unauthorized
        case .http(let status, _): self = .server(status: status)
        case .transport: self = .network
        case .decoding, .invalidRequest, .invalidResponse: self = .invalidResponse
        case .unimplemented(let name): self = .unimplemented(name)
        }
    }
}
