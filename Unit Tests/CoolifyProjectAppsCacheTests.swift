import Foundation
import Testing

struct CoolifyProjectAppsCacheTests {
    @Test func persistedAppsAndIsolatedProjects() throws {
        let suite = "CoolifyProjectAppsCacheTests.\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        let accountID = UUID()
        let domain = "https://coolify.example"
        let cache = CoolifyProjectAppsCache(accountID: accountID, domain: domain, projectUUID: "first", defaults: defaults)
        let data = Data(#"[{"uuid":"app","environmentId":1,"name":"API","environmentName":"Production"}]"#.utf8)
        let apps = try JSONDecoder().decode([CoolifyApp].self, from: data)
        try cache.save(apps)

        let restored = CoolifyProjectAppsCache(accountID: accountID, domain: domain, projectUUID: "first", defaults: defaults)
        #expect(restored.load()?.first?.uuid == "app")
        #expect(restored.load()?.first?.environmentName == "Production")
        #expect(CoolifyProjectAppsCache(accountID: accountID, domain: domain, projectUUID: "second", defaults: defaults).load() == nil)
        #expect(CoolifyProjectAppsCache(accountID: UUID(), domain: domain, projectUUID: "first", defaults: defaults).load() == nil)
        #expect(CoolifyProjectAppsCache(accountID: accountID, domain: "https://other.example", projectUUID: "first", defaults: defaults).load() == nil)

        try cache.save([])
        #expect(restored.load()?.isEmpty == true)
    }
}
