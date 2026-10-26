import Foundation

struct CoolifyDeploymentLogsCache {
    let accountID: UUID
    let domain: String
    let deploymentUUID: String
    var defaults: UserDefaults = .standard

    func load() -> CoolifyDeployment? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(CoolifyDeployment.self, from: data)
    }

    func save(_ deployment: CoolifyDeployment) throws {
        defaults.set(try JSONEncoder().encode(deployment), forKey: key)
    }

    private var key: String {
        "coolify.deploymentLogs.\(accountID).\(deploymentUUID).\(domain)"
    }
}
