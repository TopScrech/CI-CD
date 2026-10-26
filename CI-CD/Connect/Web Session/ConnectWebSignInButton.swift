import ScrechKit

@available(iOS 26, macOS 26, visionOS 26, *)
struct ConnectWebSignInButton: View {
    @State private var showSignIn = false

    let accountID: UUID
    var isReconnect = false

    var body: some View {
        Button(
            isReconnect ? "Reconnect" : "Sign in to App Store Connect",
            systemImage: "person.crop.circle"
        ) {
            showSignIn = true
        }
        .foregroundStyle(.primary)
        .sheet(isPresented: $showSignIn) {
            ConnectWebSignInView(accountID: accountID)
                .id(accountID)
        }
    }
}
