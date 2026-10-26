import Foundation
import Testing

struct ConnectWebCookieTests {
    @Test func preservedSessionCookie() throws {
        let original = try #require(HTTPCookie(properties: [
            .name: "session", .value: "test-token", .domain: ".apple.com", .path: "/",
            .secure: "TRUE", .init("HttpOnly"): "TRUE", .sameSitePolicy: "Lax"
        ]))
        let data = try JSONEncoder().encode(ConnectWebCookie(original))
        let restored = try #require(JSONDecoder().decode(ConnectWebCookie.self, from: data).cookie)
        #expect(restored.value == original.value)
        #expect(restored.domain == original.domain)
        #expect(restored.expiresDate == nil)
        #expect(restored.isSecure)
        #expect(restored.isHTTPOnly)
        #expect(restored.properties?[.sameSitePolicy] as? String == original.properties?[.sameSitePolicy] as? String)
    }

    @Test func preferredRenewedCookie() throws {
        let saved = try cookie(value: "old")
        let renewed = try cookie(value: "new")
        let merged = ConnectWebCookie.merge(saved: [saved], current: [renewed])
        #expect(merged.count == 1)
        #expect(merged.first?.value == "new")
    }

    @Test func excludedExpiredAndUnrelatedCookies() throws {
        let expired = try cookie(value: "expired", expires: .now.addingTimeInterval(-60))
        let unrelated = try cookie(value: "unrelated", domain: "notapple.com")
        #expect(ConnectWebCookie.merge(saved: [expired, unrelated], current: []).isEmpty)
        #expect(ConnectWebCookie.merge(saved: [try cookie(value: "old")], current: [expired]).isEmpty)
    }

    private func cookie(value: String, domain: String = ".apple.com", expires: Date? = nil) throws -> HTTPCookie {
        var properties: [HTTPCookiePropertyKey: Any] = [
            .name: "session", .value: value, .domain: domain, .path: "/"
        ]
        if let expires { properties[.expires] = expires }
        return try #require(HTTPCookie(properties: properties))
    }
}
