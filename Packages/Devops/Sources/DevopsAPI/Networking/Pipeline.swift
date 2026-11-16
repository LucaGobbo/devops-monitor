import Foundation

/// Runs the request through the middlewares (first = outermost); the innermost step is the transport.
func chain(_ middlewares: [DevopsMiddleware], transport: @escaping DevopsTransport) -> DevopsMiddleware.Next {
    middlewares.reversed().reduce(transport) { (next: @escaping DevopsMiddleware.Next, middleware) -> DevopsMiddleware.Next in
        { request in try await middleware.intercept(request, next) }
    }
}

/// Sends the request through the middlewares and the transport, and maps failures to ``DevopsError``.
func sendThroughMiddlewares(
    _ request: URLRequest,
    middlewares: [DevopsMiddleware],
    transport: @escaping DevopsTransport
) async throws -> (data: Data, response: HTTPURLResponse) {
    let data: Data
    let response: HTTPURLResponse
    do {
        (data, response) = try await chain(middlewares, transport: transport)(request)
    } catch let error as URLError {
        throw DevopsError.transport(error)
    }
    try validate(data, response)
    return (data, response)
}

/// 203 is how Azure DevOps answers an unauthenticated request (an HTML sign-in page); non-2xx is an error too.
func validate(_ data: Data, _ response: HTTPURLResponse) throws {
    guard (200..<300).contains(response.statusCode), response.statusCode != 203 else {
        throw DevopsError.http(status: response.statusCode, body: String(decoding: data.prefix(512), as: UTF8.self))
    }
}

/// The token for the next page of builds, if any.
func responseContinuationToken(in response: HTTPURLResponse) -> String? {
    let token = response.value(forHTTPHeaderField: "x-ms-continuationtoken")
    return token?.isEmpty == false ? token : nil
}

func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    do {
        return try JSONDecoder.devops().decode(T.self, from: data)
    } catch {
        throw DevopsError.decoding(String(describing: error))
    }
}
