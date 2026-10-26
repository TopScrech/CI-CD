import Foundation
import Testing

struct CoolifyDeploymentLogsCacheTests {
    @Test func persistedLogsAndIsolatedDeployments() throws {
        let suite = "CoolifyDeploymentLogsCacheTests.\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        let accountID = UUID()
        let domain = "https://coolify.example"
        let cache = CoolifyDeploymentLogsCache(accountID: accountID, domain: domain, deploymentUUID: "first", defaults: defaults)
        let data = Data(#"{"uuid":"app","id":1,"status":"finished","createdAt":"2026-10-26T12:00:00Z","commitMessage":"Updated app","logs":"Building\nDone"}"#.utf8)
        let deployment = try JSONDecoder().decode(CoolifyDeployment.self, from: data)
        try cache.save(deployment)

        let restored = CoolifyDeploymentLogsCache(accountID: accountID, domain: domain, deploymentUUID: "first", defaults: defaults)
        #expect(restored.load()?.uuid == "app")
        #expect(restored.load()?.status == .finished)
        #expect(restored.load()?.commitMessage == "Updated app")
        #expect(restored.load()?.createdDate != nil)
        #expect(CoolifyDeploymentLogsCache(accountID: accountID, domain: domain, deploymentUUID: "second", defaults: defaults).load() == nil)
        #expect(CoolifyDeploymentLogsCache(accountID: UUID(), domain: domain, deploymentUUID: "first", defaults: defaults).load() == nil)
        #expect(CoolifyDeploymentLogsCache(accountID: accountID, domain: "https://other.example", deploymentUUID: "first", defaults: defaults).load() == nil)

        #expect(restored.load()?.logs == "Building\nDone")
        let updated = try JSONDecoder().decode(CoolifyDeployment.self, from: Data(#"{"id":1,"status":"finished","logs":""}"#.utf8))
        try cache.save(updated)
        #expect(restored.load()?.logs == "")
    }
}
