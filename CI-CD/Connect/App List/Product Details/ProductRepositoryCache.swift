import Foundation
import AppStoreConnect_Swift_SDK

struct ProductRepositoryCache {
    let accountID: UUID
    let productID: String
    var defaults: UserDefaults = .standard

    func load(_ kind: ProductRepositoryKind) -> [ScmRepository]? {
        guard let data = defaults.data(forKey: key(for: kind)) else { return nil }
        return try? JSONDecoder().decode([ScmRepository].self, from: data)
    }

    func save(_ repositories: [ScmRepository], for kind: ProductRepositoryKind) throws {
        let data = try JSONEncoder().encode(repositories)
        defaults.set(data, forKey: key(for: kind))
    }

    private func key(for kind: ProductRepositoryKind) -> String {
        "connect.repositories.\(accountID).\(productID).\(kind.rawValue)"
    }
}
