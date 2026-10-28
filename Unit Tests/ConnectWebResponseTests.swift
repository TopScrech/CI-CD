import Foundation
import Testing

struct ConnectWebResponseTests {
    @Test func acceptedJSON() throws {
        let url = try #require(URL(string: "https://appstoreconnect.apple.com/ci/api/test"))
        let response = try #require(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "application/json; charset=utf-8"]))
        try ConnectWebResponse.validate(response, for: url)
    }

    @Test func requiredReconnectForExpiredSession() throws {
        let url = try #require(URL(string: "https://appstoreconnect.apple.com/ci/api/test"))
        let response = try #require(HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil))
        do {
            try ConnectWebResponse.validate(response, for: url)
            Issue.record("Expected sign-in error")
        } catch ConnectWebError.signInRequired {}
    }

    @Test(arguments: ["application/json", "text/html"])
    func preservedPermissionFailure(contentType: String) throws {
        let url = try #require(URL(string: "https://appstoreconnect.apple.com/ci/api/test"))
        let response = try #require(HTTPURLResponse(url: url, statusCode: 403, httpVersion: nil, headerFields: ["Content-Type": contentType]))
        do {
            try ConnectWebResponse.validate(response, for: url)
            Issue.record("Expected permission error")
        } catch ConnectWebError.accessDenied {
            #expect(!ConnectWebError.accessDenied.requiresSignIn)
        }
    }

    @Test func rejectedSignInHTML() throws {
        let url = try #require(URL(string: "https://appstoreconnect.apple.com/ci/api/test"))
        let response = try #require(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "text/html"]))
        do {
            try ConnectWebResponse.validate(response, for: url)
            Issue.record("Expected sign-in error")
        } catch ConnectWebError.signInRequired {}
    }

    @Test func requiredSignInAfterAuthenticationRedirect() throws {
        let url = try #require(URL(string: "https://appstoreconnect.apple.com/ci/api/test"))
        let signInURL = try #require(URL(string: "https://idmsa.apple.com/"))
        let response = try #require(HTTPURLResponse(url: signInURL, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "text/html"]))
        do {
            try ConnectWebResponse.validate(response, for: url)
            Issue.record("Expected sign-in error")
        } catch ConnectWebError.signInRequired {}
    }

    @Test(arguments: [404, 429, 500])
    func preservedFailureStatus(status: Int) throws {
        let url = try #require(URL(string: "https://appstoreconnect.apple.com/ci/api/test"))
        let response = try #require(HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil))
        do {
            try ConnectWebResponse.validate(response, for: url)
            Issue.record("Expected HTTP error")
        } catch ConnectWebError.httpStatus(let actualStatus) {
            #expect(actualStatus == status)
        }
    }
}
