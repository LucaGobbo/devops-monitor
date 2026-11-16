import Foundation
import Testing

@testable import DevopsAPI

/// Middlewares are tested through an echo `next` that returns what it received in the response body.
struct MiddlewareTests {
    private let echoAuthorization: DevopsMiddleware.Next = { request in
        (Data((request.value(forHTTPHeaderField: "Authorization") ?? "").utf8), httpResponse(request.url!))
    }

    private func body(_ middleware: DevopsMiddleware, next: DevopsMiddleware.Next) async throws -> String {
        String(decoding: try await middleware.intercept(getRequest(), next).0, as: UTF8.self)
    }

    // MARK: auth

    @Test func personalAccessTokenIsSentAsBasicWithEmptyUser() async throws {
        #expect(try await body(.auth(.personalAccessToken("secret")), next: echoAuthorization) == "Basic OnNlY3JldA==")   // base64(":secret")
    }

    @Test func bearerTokenIsSentAsBearer() async throws {
        #expect(try await body(.auth(.bearer("tok")), next: echoAuthorization) == "Bearer tok")
    }

    @Test func credentialClosureIsUsed() async throws {
        #expect(try await body(.auth(credential: { .bearer("fresh") }), next: echoAuthorization) == "Bearer fresh")
    }

    @Test func failingCredentialClosureStopsTheRequest() async {
        struct NoToken: Error {}
        await #expect(throws: NoToken.self) {
            _ = try await body(.auth(credential: { throw NoToken() }), next: { _ in Issue.record("next must not run"); throw NoToken() })
        }
    }

    // MARK: chain

    /// Appends `name` to a trace header, so the echo shows the order middlewares ran in.
    private func tracing(_ name: String) -> DevopsMiddleware {
        DevopsMiddleware { request, next in
            var request = request
            request.setValue((request.value(forHTTPHeaderField: "X-Trace") ?? "") + name, forHTTPHeaderField: "X-Trace")
            return try await next(request)
        }
    }

    @Test func firstMiddlewareIsOutermost() async throws {
        let echoTrace: DevopsTransport = { request in
            (Data((request.value(forHTTPHeaderField: "X-Trace") ?? "").utf8), httpResponse(request.url!))
        }
        let (data, _) = try await chain([tracing("A"), tracing("B")], transport: echoTrace)(getRequest())
        #expect(String(decoding: data, as: UTF8.self) == "AB")
    }

    @Test func middlewareCanShortCircuit() async throws {
        let canned = DevopsMiddleware { request, _ in (Data("cached".utf8), httpResponse(request.url!)) }
        let (data, _) = try await chain([canned], transport: { _ in throw URLError(.badServerResponse) })(getRequest())
        #expect(String(decoding: data, as: UTF8.self) == "cached")
    }

    // MARK: logging passes everything through

    @Test func loggingDoesNotAlterTheResponse() async throws {
        #expect(try await body(.logging(), next: echoAuthorization) == "")
    }

    @Test func loggingRethrowsErrors() async {
        await #expect(throws: URLError.self) {
            _ = try await body(.logging(), next: { _ in throw URLError(.timedOut) })
        }
    }
}
