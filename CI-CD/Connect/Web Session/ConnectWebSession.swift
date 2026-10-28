import SwiftUI
import WebKit

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
enum ConnectWebSession {
    static func makePage(accountID: UUID) -> WebPage {
        var configuration = WebPage.Configuration()
        configuration.websiteDataStore = .init(forIdentifier: accountID)
        return WebPage(configuration: configuration)
    }

    static func provider(accountID: UUID) -> ConnectWebProvider? {
        guard let data = UserDefaults.standard.data(forKey: key(accountID)) else { return nil }
        return try? JSONDecoder().decode(ConnectWebProvider.self, from: data)
    }

    static func connect(page: WebPage, accountID: UUID) async throws -> ConnectWebProvider {
        try await ConnectWebSessionQueue.withAccess(accountID: accountID) {
            let provider = try await currentProvider(page: page)
            let cookies = await WKWebsiteDataStore(forIdentifier: accountID).httpCookieStore.allCookies()
            try Task.checkCancellation()
            try ConnectWebSessionKeychain.save(cookies, accountID: accountID)
            UserDefaults.standard.set(try JSONEncoder().encode(provider), forKey: key(accountID))
            return provider
        }
    }

    static func currentProvider(page: WebPage) async throws -> ConnectWebProvider {
        guard page.url?.scheme == "https", page.url?.host == "appstoreconnect.apple.com" else {
            throw ConnectWebError.signInRequired
        }
        let result = try await page.callJavaScript("""
            const response = await fetch('/olympus/v1/session', { credentials: 'same-origin', signal: AbortSignal.timeout(10000) });
            if (!response.ok) return response.status;
            if (!response.headers.get('content-type')?.includes('json')) return null;
            const session = await response.json();
            if (!session.provider?.publicProviderId) return null;
            return JSON.stringify({ provider: {
                publicProviderId: session.provider.publicProviderId,
                name: session.provider.name
            }});
            """)
        if let status = result as? Int {
            switch status {
            case 401: throw ConnectWebError.signInRequired
            case 403: throw ConnectWebError.accessDenied
            default: throw ConnectWebError.httpStatus(status)
            }
        }
        guard let json = result as? String, let data = json.data(using: .utf8) else {
            throw ConnectWebError.signInRequired
        }
        return try JSONDecoder().decode(ConnectWebSessionInfo.self, from: data).provider
    }

    static func disconnect(accountID: UUID) async throws {
        try await ConnectWebSessionQueue.withAccess(accountID: accountID) {
            try ConnectWebSessionKeychain.delete(accountID: accountID)
            UserDefaults.standard.removeObject(forKey: key(accountID))
            let cachePrefix = "connect.web.build.\(accountID)."
            for key in UserDefaults.standard.dictionaryRepresentation().keys where key.hasPrefix(cachePrefix) || key.hasPrefix("connect.web.usage.\(accountID).") {
                UserDefaults.standard.removeObject(forKey: key)
            }
            let store = WKWebsiteDataStore(forIdentifier: accountID)
            await store.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: .distantPast)
        }
    }

    static func restoreCookies(accountID: UUID) async throws -> [HTTPCookie] {
        let store = WKWebsiteDataStore(forIdentifier: accountID).httpCookieStore
        let current = await store.allCookies()
        let saved = try ConnectWebSessionKeychain.load(accountID: accountID)
        let cookies = ConnectWebCookie.merge(saved: saved, current: current)
        for cookie in cookies {
            await store.setCookie(cookie)
        }
        return cookies
    }

    // The caller holds the account queue throughout recovery and the retry
    static func recover(accountID: UUID, provider: ConnectWebProvider) async throws {
        let page = makePage(accountID: accountID)
        guard let url = URL(string: "https://appstoreconnect.apple.com/") else {
            throw ConnectWebError.signInRequired
        }
        let timeout = Task {
            try await Task.sleep(for: .seconds(30))
            page.stopLoading()
        }
        defer {
            timeout.cancel()
            page.stopLoading()
        }
        for try await _ in page.load(URLRequest(url: url, timeoutInterval: 30)) {
            try Task.checkCancellation()
        }
        try Task.checkCancellation()
        let current = try await currentProvider(page: page)
        guard current.publicProviderId == provider.publicProviderId else {
            throw ConnectWebError.wrongTeam
        }
        let cookies = await WKWebsiteDataStore(forIdentifier: accountID).httpCookieStore.allCookies()
        try Task.checkCancellation()
        try ConnectWebSessionKeychain.save(cookies, accountID: accountID)
    }

    private static func key(_ accountID: UUID) -> String {
        "connect.web.provider.\(accountID)"
    }
}
