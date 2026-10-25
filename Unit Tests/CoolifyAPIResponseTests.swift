import Foundation
import Testing

struct CoolifyAPIResponseTests {
    @Test func decodedProjects() throws {
        let data = Data(#"[{"id":1,"uuid":"project-id","name":"Production","description":null}]"#.utf8)
        let projects = try CoolifyAPIResponse.decode([CoolifyProject].self, from: data, response: response(200))

        #expect(projects.count == 1)
        #expect(projects.first?.name == "Production")
        #expect(projects.first?.description == nil)
    }

    @Test func decodedEmptyProjects() throws {
        let projects = try CoolifyAPIResponse.decode([CoolifyProject].self, from: Data("[]".utf8), response: response(200))
        #expect(projects.isEmpty)
    }

    @Test(arguments: [400, 401, 403, 429, 500])
    func preservedAPIError(statusCode: Int) throws {
        // Coolify's IP allowlist rejection includes success: true despite HTTP 403
        let data = Data(#"{"success":true,"message":"Access denied"}"#.utf8)

        do {
            _ = try CoolifyAPIResponse.decode([CoolifyProject].self, from: data, response: response(statusCode))
            Issue.record("Expected an API error")
        } catch CoolifyAPIError.requestFailed(let actualStatus, let message) {
            #expect(actualStatus == statusCode)
            #expect(message == "Access denied")
        }
    }

    @Test func handledNonJSONError() throws {
        let data = Data("<html>Bad gateway</html>".utf8)

        do {
            _ = try CoolifyAPIResponse.decode([CoolifyProject].self, from: data, response: response(502))
            Issue.record("Expected an API error")
        } catch CoolifyAPIError.requestFailed(let statusCode, let message) {
            #expect(statusCode == 502)
            #expect(message == nil)
        }
    }

    @Test func rejectedMalformedSuccess() throws {
        #expect(throws: DecodingError.self) {
            try CoolifyAPIResponse.decode([CoolifyProject].self, from: Data("{}".utf8), response: response(200))
        }
    }

    private func response(_ statusCode: Int) throws -> HTTPURLResponse {
        let url = try #require(URL(string: "https://coolify.example.com/api/v1/projects"))
        return try #require(HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil))
    }
}
