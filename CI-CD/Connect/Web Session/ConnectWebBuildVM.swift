import SwiftUI

@Observable
final class ConnectWebBuildVM {
    private(set) var summary: ConnectWebBuildSummary?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private var requestID = UUID()

    @available(iOS 26, macOS 26, visionOS 26, *)
    func load(accountID: UUID, productID: String?, buildID: String, buildNumber: Int?) async {
        let requestID = UUID()
        self.requestID = requestID
        isLoading = false
        summary = nil
        errorMessage = nil
        guard let provider = ConnectWebSession.provider(accountID: accountID) else { return }
        guard let productID, let buildNumber else {
            errorMessage = ConnectWebError.summaryUnavailable.errorDescription
            return
        }
        let key = "connect.web.build.\(accountID).\(provider.publicProviderId).\(productID).\(buildID)"
        if let data = UserDefaults.standard.data(forKey: key) {
            summary = try? JSONDecoder().decode(ConnectWebBuildSummary.self, from: data)
        }
        isLoading = true
        defer { if self.requestID == requestID { isLoading = false } }
        do {
            let summary = try await ConnectWebClient.buildSummary(
                accountID: accountID,
                provider: provider,
                productID: productID,
                buildID: buildID
            )
            try Task.checkCancellation()
            guard self.requestID == requestID,
                  ConnectWebSession.provider(accountID: accountID) == provider else { return }
            guard summary.build.id.caseInsensitiveCompare(buildID) == .orderedSame,
                  summary.build.number == buildNumber else { throw ConnectWebError.summaryUnavailable }
            self.summary = summary
            UserDefaults.standard.set(try JSONEncoder().encode(summary), forKey: key)
        } catch is CancellationError {
            return
        } catch {
            guard self.requestID == requestID else { return }
            if let webError = error as? ConnectWebError {
                errorMessage = webError.errorDescription
            } else if let decodingError = error as? DecodingError {
                errorMessage = ConnectWebError.decodingDescription(decodingError)
            } else {
                errorMessage = String(localized: "Could not load the build summary") + "\n" + error.localizedDescription
            }
        }
    }
}
