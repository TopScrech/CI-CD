import Foundation
import Testing

struct CoolifyProjectCacheTests {
    @Test func persistedProjectsAndIsolatedAccountsAndServers() throws {
        let suite = "CoolifyProjectCacheTests.\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        let accountID = UUID()
        let cache = CoolifyProjectCache(accountID: accountID, domain: "https://first.example", defaults: defaults)
        let projects = [CoolifyProject(id: 1, uuid: "project", name: "Production", description: nil)]
        try cache.save(projects)

        let restored = CoolifyProjectCache(accountID: accountID, domain: cache.domain, defaults: defaults)
        #expect(restored.load() == projects)
        #expect(CoolifyProjectCache(accountID: UUID(), domain: cache.domain, defaults: defaults).load() == nil)
        #expect(CoolifyProjectCache(accountID: accountID, domain: "https://second.example", defaults: defaults).load() == nil)

        try cache.save([])
        #expect(restored.load() == [])
    }
}
