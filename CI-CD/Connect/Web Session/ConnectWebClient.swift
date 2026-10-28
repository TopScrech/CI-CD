import Foundation
import WebKit

@available(iOS 26, macOS 26, visionOS 26, *)
enum ConnectWebClient {
    static func buildSummary(accountID: UUID, provider: ConnectWebProvider, productID: String, buildID: String) async throws -> ConnectWebBuildSummary {
        let data = try await authenticatedData(accountID: accountID, provider: provider, path: ["products", productID, "builds", buildID, "details-v3"])
        return try ConnectWebBuildSummary.decode(data)
    }

    static func usage(accountID: UUID, provider: ConnectWebProvider) async throws -> ConnectUsagePlan {
        let data = try await authenticatedData(accountID: accountID, provider: provider, path: ["usage", "summary"])
        return try JSONDecoder().decode(ConnectUsageSummary.self, from: data).plan
    }

    private static func authenticatedData(accountID: UUID, provider: ConnectWebProvider, path: [String]) async throws -> Data {
        try await ConnectWebSessionQueue.withAccess(accountID: accountID) {
            guard ConnectWebSession.provider(accountID: accountID) == provider else {
                throw ConnectWebError.signInRequired
            }
            return try await ConnectWebRecovery.data {
                try await requestData(accountID: accountID, provider: provider, path: path)
            } recover: {
                try await ConnectWebSession.recover(accountID: accountID, provider: provider)
            }
        }
    }

    private static func requestData(accountID: UUID, provider: ConnectWebProvider, path: [String]) async throws -> Data {
        let cookies = try await ConnectWebSession.restoreCookies(accountID: accountID)
        try Task.checkCancellation()

        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        for cookie in cookies {
            configuration.httpCookieStorage?.setCookie(cookie)
        }
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel() }

        guard let baseURL = URL(string: "https://appstoreconnect.apple.com") else {
            throw ConnectWebError.summaryUnavailable
        }
        let responseData: Data
        do {
            let sessionData = try await data(from: baseURL.appending(path: "olympus/v1/session"), session: session)
            let currentProvider = try JSONDecoder().decode(ConnectWebSessionInfo.self, from: sessionData).provider
            guard currentProvider.publicProviderId == provider.publicProviderId else {
                throw ConnectWebError.wrongTeam
            }

            let endpoint = (["ci", "api", "teams", provider.publicProviderId] + path).reduce(baseURL) { $0.appending(component: $1) }
            responseData = try await data(from: endpoint, session: session)
        } catch {
            // Session probes can rotate cookies even if the resource request fails
            try await persistCookies(accountID: accountID, original: cookies, updated: configuration.httpCookieStorage?.cookies ?? [])
            throw error
        }
        try await persistCookies(accountID: accountID, original: cookies, updated: configuration.httpCookieStorage?.cookies ?? [])
        return responseData
    }

    private static func persistCookies(accountID: UUID, original: [HTTPCookie], updated: [HTTPCookie]) async throws {
        try Task.checkCancellation()
        let store = WKWebsiteDataStore(forIdentifier: accountID).httpCookieStore
        let current = ConnectWebCookie.merge(saved: [], current: await store.allCookies())
        let reconciled = ConnectWebCookie.reconcile(original: original, updated: updated, current: current)
        try Task.checkCancellation()
        for cookie in current {
            let identity = ConnectWebCookie(cookie).identity
            if !reconciled.contains(where: { ConnectWebCookie($0).identity == identity }) {
                await store.deleteCookie(cookie)
            }
        }
        for cookie in reconciled where !current.contains(where: { ConnectWebCookie($0) == ConnectWebCookie(cookie) }) {
            await store.setCookie(cookie)
        }
        let latest = await store.allCookies()
        try Task.checkCancellation()
        try ConnectWebSessionKeychain.save(latest, accountID: accountID)
    }

    private static func data(from url: URL, session: URLSession) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await session.data(for: request)
        try ConnectWebResponse.validate(response, for: url)
        return data
    }
}
