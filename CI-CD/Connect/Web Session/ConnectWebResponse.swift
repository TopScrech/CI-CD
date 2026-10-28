import Foundation

enum ConnectWebResponse {
    static func validate(_ response: URLResponse, for url: URL) throws {
        guard let response = response as? HTTPURLResponse else {
            throw ConnectWebError.summaryUnavailable
        }
        guard response.url?.host == url.host,
              response.statusCode != 401 else {
            throw ConnectWebError.signInRequired
        }
        guard response.statusCode != 403 else {
            throw ConnectWebError.accessDenied
        }
        guard (200..<300).contains(response.statusCode) else {
            throw ConnectWebError.httpStatus(response.statusCode)
        }
        guard response.mimeType?.contains("json") == true else {
            throw ConnectWebError.signInRequired
        }
    }
}
