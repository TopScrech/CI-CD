import Foundation

@Observable
final class ConnectUsageVM {
    private(set) var plan: ConnectUsagePlan?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private var requestID = UUID()

    func reset() {
        requestID = UUID()
        plan = nil
        isLoading = false
        errorMessage = nil
    }

    @available(iOS 26, macOS 26, visionOS 26, *)
    func load(accountID: UUID) async {
        reset()
        guard let provider = ConnectWebSession.provider(accountID: accountID) else { return }
        let requestID = requestID
        let key = "connect.web.usage.\(accountID).\(provider.publicProviderId)"
        if let data = UserDefaults.standard.data(forKey: key) {
            plan = try? JSONDecoder().decode(ConnectUsagePlan.self, from: data)
        }
        isLoading = true
        defer { if self.requestID == requestID { isLoading = false } }
        do {
            let plan = try await ConnectWebClient.usage(accountID: accountID, provider: provider)
            try Task.checkCancellation()
            guard self.requestID == requestID,
                  ConnectWebSession.provider(accountID: accountID) == provider else { return }
            self.plan = plan
            UserDefaults.standard.set(try JSONEncoder().encode(plan), forKey: key)
        } catch is CancellationError {
            return
        } catch {
            guard self.requestID == requestID else { return }
            errorMessage = (error as? ConnectWebError)?.requiresSignIn == true
                ? String(localized: "Sign in to refresh quota")
                : String(localized: "Could not refresh quota")
        }
    }
}
