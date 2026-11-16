import Foundation
import Testing
@testable import DevopsAPI

/// Pure functions: response in, error (or value) out.
struct ResponseTests {
    private let url = URL(string: "https://dev.azure.com/x")!

    @Test func successPasses() throws {
        try validate(Data(), httpResponse(url, status: 200))
    }

    @Test func nonSuccessBecomesHttpError() {
        #expect(throws: DevopsError.http(status: 401, body: "nope")) {
            try validate(Data("nope".utf8), httpResponse(url, status: 401))
        }
    }

    @Test func unauthenticatedSignInPageBecomesHttpError() {
        #expect(throws: DevopsError.http(status: 203, body: "<html>")) {
            try validate(Data("<html>".utf8), httpResponse(url, status: 203))
        }
    }

    @Test func longErrorBodiesAreTruncated() {
        let error = #expect(throws: DevopsError.self) {
            try validate(Data(String(repeating: "x", count: 5_000).utf8), httpResponse(url, status: 500))
        }
        guard case .http(_, let body)? = error else {
            Issue.record("Expected .http, got \(String(describing: error))")
            return
        }
        #expect(body.count == 512)
    }

    @Test func malformedBodyBecomesDecodingError() {
        let error = #expect(throws: DevopsError.self) { try decode(ProjectDTO.self, from: Data("{ not json".utf8)) }
        guard case .decoding? = error else {
            Issue.record("Expected .decoding, got \(String(describing: error))")
            return
        }
    }

    @Test func continuationTokenIsReadCaseInsensitively() {
        #expect(responseContinuationToken(in: httpResponse(url, headers: ["X-MS-ContinuationToken": "next"])) == "next")
        #expect(responseContinuationToken(in: httpResponse(url, headers: ["x-ms-continuationtoken": ""])) == nil)
        #expect(responseContinuationToken(in: httpResponse(url)) == nil)
    }
}
