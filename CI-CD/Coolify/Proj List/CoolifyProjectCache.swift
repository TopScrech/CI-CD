import Foundation

struct CoolifyProjectCache {
    let accountID: UUID
    let domain: String
    var defaults: UserDefaults = .standard

    func load() -> [CoolifyProject]? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode([CoolifyProject].self, from: data)
    }

    func save(_ projects: [CoolifyProject]) throws {
        defaults.set(try JSONEncoder().encode(projects), forKey: key)
    }

    private var key: String {
        "coolify.projects.\(accountID).\(domain)"
    }
}
