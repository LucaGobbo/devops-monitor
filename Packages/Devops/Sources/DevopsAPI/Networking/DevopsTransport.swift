import Foundation

/// Performs one HTTP request. The default talks to `URLSession.shared`; inject your own to customise or replace it.
public typealias DevopsTransport = @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)

extension DevopsAPI {
    /// The default transport: `URLSession.shared`.
    public static let urlSessionTransport: DevopsTransport = { request in
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw DevopsError.invalidResponse }
        return (data, http)
    }
}
