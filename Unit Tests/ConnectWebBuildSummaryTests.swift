import Foundation
import Testing

struct ConnectWebBuildSummaryTests {
    @Test func decodedEnvironmentAndActualUsage() throws {
        let data = Data(#"{"build":{"id":"build-id","number":160,"state":"succeeded","started_at":"2026-10-25T10:00:00.000Z","finished_at":"2026-10-25T22:42:00Z"},"builder_name":"Xcode 27.2 RC (27B48)","os_name":"macOS Golden Gate 27.2 RC (26B118)","total_usage_time":180}"#.utf8)
        let summary = try ConnectWebBuildSummary.decode(data)
        #expect(summary.xcode == "Xcode 27.2 RC (27B48)")
        #expect(summary.macOS == "macOS Golden Gate 27.2 RC (26B118)")
        #expect(summary.duration == 45_720)
        #expect(summary.usage == 180)
        let cached = try JSONDecoder().decode(ConnectWebBuildSummary.self, from: JSONEncoder().encode(summary))
        #expect(cached == summary)
    }

    @Test(arguments: ["running", "pending-beta-review", "pending"])
    func omittedUnfinishedUsage(state: String) throws {
        let data = Data("{\"build\":{\"id\":\"build-id\",\"number\":1,\"state\":\"\(state)\"},\"total_usage_time\":0}".utf8)
        let summary = try ConnectWebBuildSummary.decode(data)
        #expect(summary.usage == nil)
        #expect(summary.duration == nil)
        #expect(summary.xcode == nil)
        #expect(summary.macOS == nil)
    }

    @Test func rejectedNegativeTimings() throws {
        let data = Data(#"{"build":{"id":"build-id","number":1,"state":"failed","started_at":"2026-10-25T11:00:00Z","finished_at":"2026-10-25T10:00:00Z"},"total_usage_time":-1}"#.utf8)
        let summary = try ConnectWebBuildSummary.decode(data)
        #expect(summary.duration == nil)
        #expect(summary.usage == nil)
    }

    @Test func rejectedSignInPage() {
        #expect(throws: DecodingError.self) {
            try ConnectWebBuildSummary.decode(Data("<html>Sign in</html>".utf8))
        }
    }
}
