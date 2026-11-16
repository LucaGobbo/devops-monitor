import Foundation

func httpResponse(_ url: URL, status: Int = 200, headers: [String: String] = [:]) -> HTTPURLResponse {
    HTTPURLResponse(url: url, statusCode: status, httpVersion: "HTTP/1.1", headerFields: headers)!
}

func getRequest(_ string: String = "https://dev.azure.com/x?api-version=7.1") -> URLRequest {
    URLRequest(url: URL(string: string)!)
}
