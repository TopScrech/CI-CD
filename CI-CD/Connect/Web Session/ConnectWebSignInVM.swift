import SwiftUI
import WebKit

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
@Observable
final class ConnectWebSignInVM {
    let accountID: UUID
    let page: WebPage
    var isConnecting = false
    var errorMessage: String?

    init(accountID: UUID) {
        self.accountID = accountID
        page = ConnectWebSession.makePage(accountID: accountID)
    }

    func load() async {
        do {
            _ = try await ConnectWebSession.restoreCookies(accountID: accountID)
            for try await _ in page.load(URL(string: "https://appstoreconnect.apple.com/")) {}
        } catch is CancellationError {
            return
        } catch {
            errorMessage = String(localized: "Could not load App Store Connect")
        }
    }

    func connect() async -> Bool {
        guard !isConnecting else { return false }
        isConnecting = true
        errorMessage = nil
        defer { isConnecting = false }
        do {
            _ = try await ConnectWebSession.connect(page: page, accountID: accountID)
            return true
        } catch {
            errorMessage = error is ConnectWebError
                ? String(localized: "Finish signing in and select your team, then tap Connect")
                : error.localizedDescription
            return false
        }
    }
}
