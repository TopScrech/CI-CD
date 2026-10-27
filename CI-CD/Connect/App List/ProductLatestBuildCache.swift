import Foundation
import ASC

struct ProductLatestBuildCache {
    let accountID: UUID
    let productID: String
    var defaults: UserDefaults = .standard

    func load() -> CiBuildRun? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(CiBuildRun.self, from: data)
    }

    func save(_ build: CiBuildRun?) throws {
        guard let build else {
            defaults.removeObject(forKey: key)
            defaults.removeObject(forKey: key + ".betaStates")
            return
        }
        defaults.set(try JSONEncoder().encode(build), forKey: key)
    }

    func loadBetaStates() -> [String: [ExternalBetaState]] {
        guard let data = defaults.data(forKey: key + ".betaStates") else { return [:] }
        return (try? JSONDecoder().decode([String: [ExternalBetaState]].self, from: data)) ?? [:]
    }

    func saveBetaStates(_ states: [ExternalBetaState], for buildID: String) throws {
        defaults.set(try JSONEncoder().encode([buildID: states]), forKey: key + ".betaStates")
    }

    private var key: String {
        "connect.latestBuild.\(accountID).\(productID)"
    }
}
