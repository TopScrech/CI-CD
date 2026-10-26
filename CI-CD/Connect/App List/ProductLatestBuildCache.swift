import Foundation
import AppStoreConnect_Swift_SDK

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
            return
        }
        defaults.set(try JSONEncoder().encode(build), forKey: key)
    }

    private var key: String {
        "connect.latestBuild.\(accountID).\(productID)"
    }
}
