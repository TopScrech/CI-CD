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

    @Test func keptNewerWebKitCookieOverStaleResponse() throws {
        let original = try cookie(value: "old")
        let response = try cookie(value: "response")
        let newer = try cookie(value: "web-sign-in")
        let result = ConnectWebCookie.reconcile(original: [original], updated: [response], current: [newer])
        #expect(result.first?.value == "web-sign-in")
    }

    @Test func appliedRotationAndPreservedOtherCookies() throws {
        let original = try cookie(value: "old")
        let response = try cookie(value: "response")
        let other = try cookie(value: "sso", domain: "idmsa.apple.com")
        let result = ConnectWebCookie.reconcile(original: [original], updated: [response], current: [original, other])
        #expect(result.count == 2)
        #expect(result.contains { $0.value == "response" })
        #expect(result.contains { $0.value == "sso" })
    }

    @Test func respectedServerDeletionWithoutDeletingNewerCookie() throws {
        let original = try cookie(value: "old")
        let newer = try cookie(value: "new")
        #expect(ConnectWebCookie.reconcile(original: [original], updated: [], current: [original]).isEmpty)
        #expect(ConnectWebCookie.reconcile(original: [original], updated: [], current: [newer]).first?.value == "new")
    }

    private func cookie(value: String, domain: String = ".apple.com", expires: Date? = nil) throws -> HTTPCookie {
        var properties: [HTTPCookiePropertyKey: Any] = [
            .name: "session", .value: value, .domain: domain, .path: "/"
        ]
        if let expires { properties[.expires] = expires }
        return try #require(HTTPCookie(properties: properties))
    }
}
