import Foundation
import Testing

struct CoolifyDeploymentCacheTests {
    @Test func persistedDeploymentsAndIsolatedApps() throws {
        let suite = "CoolifyDeploymentCacheTests.\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        let accountID = UUID()
        let domain = "https://coolify.example"
        let cache = CoolifyDeploymentCache(accountID: accountID, domain: domain, appUUID: "first", defaults: defaults)
        let data = Data(#"[{"uuid":"app","id":1,"status":"finished","createdAt":"2026-10-26T12:00:00Z","commitMessage":"Updated app"}]"#.utf8)
        let deployments = try JSONDecoder().decode([CoolifyDeployment].self, from: data)
        try cache.save(deployments)

        let restored = CoolifyDeploymentCache(accountID: accountID, domain: domain, appUUID: "first", defaults: defaults)
        #expect(restored.load()?.first?.uuid == "app")
        #expect(restored.load()?.first?.status == .finished)
        #expect(restored.load()?.first?.commitMessage == "Updated app")
        #expect(restored.load()?.first?.createdDate != nil)
        #expect(CoolifyDeploymentCache(accountID: accountID, domain: domain, appUUID: "second", defaults: defaults).load() == nil)
        #expect(CoolifyDeploymentCache(accountID: UUID(), domain: domain, appUUID: "first", defaults: defaults).load() == nil)
        #expect(CoolifyDeploymentCache(accountID: accountID, domain: "https://other.example", appUUID: "first", defaults: defaults).load() == nil)

        try cache.save([])
        #expect(restored.load()?.isEmpty == true)
    }
}
