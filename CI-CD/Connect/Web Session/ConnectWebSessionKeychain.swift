import Foundation
import Security

enum ConnectWebSessionKeychain {
    private static func query(accountID: UUID) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "dev.topscrech.CI-CD.connect-web-session",
            kSecAttrAccount as String: accountID.uuidString,
            kSecAttrSynchronizable as String: false
        ]
    }

    static func load(accountID: UUID) throws -> [HTTPCookie] {
        var query = query(accountID: accountID)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return [] }
        guard status == errSecSuccess else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(status)) }
        guard let data = result as? Data else { return [] }
        return try JSONDecoder().decode([ConnectWebCookie].self, from: data).compactMap(\.cookie)
    }

    static func save(_ cookies: [HTTPCookie], accountID: UUID) throws {
        let data = try JSONEncoder().encode(ConnectWebCookie.merge(saved: [], current: cookies).map(ConnectWebCookie.init))
        let query = query(accountID: accountID)
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            let result = SecItemAdd(query.merging(attributes) { _, new in new } as CFDictionary, nil)
            guard result == errSecSuccess else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(result)) }
        } else if status != errSecSuccess {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }

    static func delete(accountID: UUID) throws {
        let status = SecItemDelete(query(accountID: accountID) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }
}
