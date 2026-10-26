import Foundation

struct ConnectWebCookie: Codable {
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
