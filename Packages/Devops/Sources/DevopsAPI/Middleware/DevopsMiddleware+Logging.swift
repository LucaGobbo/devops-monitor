import Foundation
import os

extension DevopsMiddleware {
    /// Logs method, URL, status code, duration and failures of every request through `os.Logger`
    /// (and with `print` in DEBUG builds).
    ///
    /// Headers (so never the `Authorization` value) and request/response bodies are not logged.
    public static func logging(subsystem: String = "Devops", category: String = "http") -> DevopsMiddleware {
        logging(logger: Logger(subsystem: subsystem, category: category)) { line in
            #if DEBUG
            print(line)
            #endif
        }
    }

    static func logging(logger: Logger, emit: @escaping @Sendable (String) -> Void) -> DevopsMiddleware {
        DevopsMiddleware { request, next in
            let method = request.httpMethod ?? "GET"
            let url = request.url?.absoluteString ?? "<no url>"
            let clock = ContinuousClock()
            let start = clock.now
            do {
                let result = try await next(request)
                let status = result.1.statusCode
                let ms = start.milliseconds(until: clock.now)
                logger.info("\(method, privacy: .public) \(url, privacy: .private) -> \(status, privacy: .public) (\(ms, privacy: .public) ms)")
                emit("[Devops] \(method) \(url) -> \(status) (\(ms) ms)")
                return result
            } catch {
                let ms = start.milliseconds(until: clock.now)
                let reason = error.localizedDescription
                logger.error("\(method, privacy: .public) \(url, privacy: .private) failed after \(ms, privacy: .public) ms: \(reason, privacy: .public)")
                emit("[Devops] \(method) \(url) failed after \(ms) ms: \(reason)")
                throw error
            }
        }
    }
}

private extension ContinuousClock.Instant {
    func milliseconds(until end: ContinuousClock.Instant) -> Int {
        let parts = duration(to: end).components
        return Int(parts.seconds * 1000 + parts.attoseconds / 1_000_000_000_000_000)
    }
}
