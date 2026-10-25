import Foundation
import Security

enum CoolifyProxyKeychain {
    private static func query(accountID: UUID) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "dev.topscrech.CI-CD.coolify-proxy",
            kSecAttrAccount as String: accountID.uuidString,
            kSecAttrSynchronizable as String: true
        ]
    }

    static func load(accountID: UUID) throws -> CoolifyProxyCredentials? {
        var query = query(accountID: accountID)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess else { throw CoolifyProxyError.keychain(status) }
        guard let data = result as? Data else { throw CoolifyProxyError.missingCredentials }
        return try JSONDecoder().decode(CoolifyProxyCredentials.self, from: data)
    }

    static func save(_ credentials: CoolifyProxyCredentials, accountID: UUID) throws {
        let data = try JSONEncoder().encode(credentials)
        let query = query(accountID: accountID)
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            let item = query.merging(attributes) { _, new in new }
            let addStatus = SecItemAdd(item as CFDictionary, nil)
            guard addStatus == errSecSuccess else { throw CoolifyProxyError.keychain(addStatus) }
        } else if status != errSecSuccess {
            throw CoolifyProxyError.keychain(status)
        }
    }
}
