import Foundation

struct ConnectWebCookie: Codable, Equatable {
    let name: String
    let value: String
    let domain: String
    let path: String
    let expires: Date?
    let secure: Bool
    let httpOnly: Bool
    let sameSite: String?

    init(_ cookie: HTTPCookie) {
        name = cookie.name
        value = cookie.value
        domain = cookie.domain
        path = cookie.path
        expires = cookie.expiresDate
        secure = cookie.isSecure
        httpOnly = cookie.isHTTPOnly
        sameSite = cookie.properties?[.sameSitePolicy] as? String
    }

    var identity: String { "\(domain)|\(path)|\(name)" }

    var cookie: HTTPCookie? {
        guard expires.map({ $0 > .now }) ?? true else { return nil }
        var properties: [HTTPCookiePropertyKey: Any] = [
            .name: name, .value: value, .domain: domain, .path: path
        ]
        if let expires { properties[.expires] = expires }
        if secure { properties[.secure] = "TRUE" }
        if httpOnly { properties[.init("HttpOnly")] = "TRUE" }
        if let sameSite { properties[.sameSitePolicy] = sameSite }
        return HTTPCookie(properties: properties)
    }

    // Apply only response changes whose original value is still current
    static func reconcile(original: [HTTPCookie], updated: [HTTPCookie], current: [HTTPCookie]) -> [HTTPCookie] {
        func indexed(_ cookies: [HTTPCookie]) -> [String: ConnectWebCookie] {
            cookies.reduce(into: [:]) {
                let cookie = Self($1)
                $0[cookie.identity] = cookie
            }
        }
        let original = indexed(original)
        let updated = indexed(updated)
        var result = indexed(current)
        for identity in Set(original.keys).union(updated.keys) {
            guard original[identity] != updated[identity], result[identity] == original[identity] else { continue }
            result[identity] = updated[identity]
        }
        return merge(saved: [], current: result.values.compactMap(\.cookie))
    }

    static func merge(saved: [HTTPCookie], current: [HTTPCookie]) -> [HTTPCookie] {
        var cookies: [String: ConnectWebCookie] = [:]
        for cookie in saved + current {
            let domain = cookie.domain.lowercased()
            guard domain == "apple.com" || domain.hasSuffix(".apple.com") else { continue }
            let stored = Self(cookie)
            cookies[stored.identity] = stored
        }
        return cookies.values.compactMap(\.cookie)
    }
}
