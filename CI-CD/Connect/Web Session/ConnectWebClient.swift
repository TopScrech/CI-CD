import Foundation
import WebKit

@available(iOS 26, macOS 26, visionOS 26, *)
enum ConnectWebClient {
    static func buildSummary(accountID: UUID, provider: ConnectWebProvider, productID: String, buildID: String) async throws -> ConnectWebBuildSummary {
        let cookieStore = WKWebsiteDataStore(forIdentifier: accountID).httpCookieStore
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
        let sessionData = try await data(from: baseURL.appending(path: "olympus/v1/session"), session: session)
        let currentProvider = try JSONDecoder().decode(ConnectWebSessionInfo.self, from: sessionData).provider
        guard currentProvider.publicProviderId == provider.publicProviderId else {
            throw ConnectWebError.wrongTeam
        }

        let endpoint = baseURL.appending(components: "ci", "api", "teams", provider.publicProviderId, "products", productID, "builds", buildID, "details-v3")
        let responseData = try await data(from: endpoint, session: session)
        let summary = try ConnectWebBuildSummary.decode(responseData)

        try Task.checkCancellation()
        // Do not restore session cookies if the user disconnected during the request
        if ConnectWebSession.provider(accountID: accountID) == provider {
            let renewedCookies = configuration.httpCookieStorage?.cookies ?? []
            try ConnectWebSessionKeychain.save(renewedCookies, accountID: accountID)
            for cookie in renewedCookies {
                await cookieStore.setCookie(cookie)
            }
        }
        return summary
    }

    private static func data(from url: URL, session: URLSession) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await session.data(for: request)
        try ConnectWebResponse.validate(response, for: url)
        return data
    }
}
