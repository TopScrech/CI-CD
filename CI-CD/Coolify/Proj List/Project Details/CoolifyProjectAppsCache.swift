import Foundation

struct CoolifyProjectAppsCache {
    let accountID: UUID
    let domain: String
    let projectUUID: String
    var defaults: UserDefaults = .standard

    func load() -> [CoolifyApp]? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode([CoolifyApp].self, from: data)
    }

    func save(_ apps: [CoolifyApp]) throws {
        defaults.set(try JSONEncoder().encode(apps), forKey: key)
    }

    private var key: String {
        "coolify.projectApps.\(accountID).\(projectUUID).\(domain)"
    }
}
