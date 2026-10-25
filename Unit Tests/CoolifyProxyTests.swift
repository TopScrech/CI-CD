import Foundation
import Testing

struct CoolifyProxyTests {
    @Test func acceptedHTTPSProxy() throws {
        let credentials = CoolifyProxyCredentials(url: "https://proxy.example.com", username: "test-user", password: "test-password")
        let proxy = try credentials.configuration()
        #expect(!proxy.allowFailover)
    }

    @Test(arguments: [
        "",
        "http://proxy.topscrech.dev",
        "proxy.topscrech.dev",
        "https://proxy.topscrech.dev/path",
        "https://proxy.topscrech.dev?token=secret",
        "https://proxy.topscrech.dev#fragment",
        "https://user:secret@proxy.topscrech.dev",
        "https://proxy.topscrech.dev:0",
        "https://proxy.topscrech.dev:65536"
    ])
    func rejectedInvalidURL(url: String) {
        let credentials = CoolifyProxyCredentials(url: url, username: "test-user", password: "test-password")
        #expect(throws: CoolifyProxyError.self) {
            try credentials.configuration()
        }
    }

    @Test func decodedLegacyCredentialsWithoutInventingUsername() throws {
        let data = Data(#"{"url":"https://proxy.example.com","password":"saved-password"}"#.utf8)
        let credentials = try JSONDecoder().decode(CoolifyProxyCredentials.self, from: data)
        #expect(credentials.url == "https://proxy.example.com")
        #expect(credentials.password == "saved-password")
        #expect(credentials.username.isEmpty)
        #expect(throws: CoolifyProxyError.self) {
            try credentials.configuration()
        }
    }

    @Test func preservedUsernameInKeychainPayload() throws {
        let original = CoolifyProxyCredentials(url: "https://proxy.example.com", username: "another-user", password: "test-password")
        let data = try JSONEncoder().encode(original)
        #expect(try JSONDecoder().decode(CoolifyProxyCredentials.self, from: data) == original)
    }

    @Test func requiredPassword() {
        #expect(throws: CoolifyProxyError.self) {
            try CoolifyProxyCredentials(url: "https://proxy.example.com", username: "test-user").configuration()
        }
    }

    @Test func acceptedExplicitPortAndWhitespace() throws {
        let credentials = CoolifyProxyCredentials(url: " https://proxy.topscrech.dev:443/\n", username: "test-user", password: "test-password")
        _ = try credentials.configuration()
    }
}
