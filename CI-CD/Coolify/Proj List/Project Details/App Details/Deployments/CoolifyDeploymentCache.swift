import Foundation

struct CoolifyDeploymentCache {
    let accountID: UUID
    let domain: String
    let appUUID: String
    var defaults: UserDefaults = .standard

    func load() -> [CoolifyDeployment]? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode([CoolifyDeployment].self, from: data)
    }

    func save(_ deployments: [CoolifyDeployment]) throws {
        defaults.set(try JSONEncoder().encode(deployments), forKey: key)
    }

    private var key: String {
        "coolify.deployments.\(accountID).\(appUUID).\(domain)"
    }
}
