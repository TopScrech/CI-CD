import ScrechKit

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
struct ConnectWebAccountSectionView: View {
    @EnvironmentObject private var store: ValueStore
    @State private var errorMessage: String?
    @State private var provider: ConnectWebProvider?

    let accountID: UUID

    var body: some View {
        Section {
            if let provider {
                LabeledContent("Team", value: provider.name)

                ConnectWebSignInButton(accountID: accountID, isReconnect: true)

                AsyncButton("Disconnect", systemImage: "person.crop.circle.badge.minus", role: .destructive) {
                    do {
                        try await ConnectWebSession.disconnect(accountID: accountID)
                        self.provider = nil
                        errorMessage = nil
                        store.bumpRefreshToken(for: .connect)
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            } else {
                ConnectWebSignInButton(accountID: accountID)
            }
            if let errorMessage {
                Text(errorMessage)
                    .secondary()
            }
        } header: {
            Text("Apple Account")
        } footer: {
            Text("Connect your Apple Account to show the build’s Xcode and macOS versions, duration, and usage time")
        }
        .task(id: accountID) { provider = ConnectWebSession.provider(accountID: accountID) }
        .onChange(of: store.connectRefreshToken) {
            provider = ConnectWebSession.provider(accountID: accountID)
        }
    }
}
