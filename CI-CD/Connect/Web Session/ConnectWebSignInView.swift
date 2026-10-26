import ScrechKit
import WebKit

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
struct ConnectWebSignInView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ValueStore
    @State private var vm: ConnectWebSignInVM

    init(accountID: UUID) {
        _vm = State(initialValue: ConnectWebSignInVM(accountID: accountID))
    }

    var body: some View {
        NavigationStack {
            VStack {
                if let errorMessage = vm.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                        .padding()
                }

                WebView(vm.page)
            }
            .navigationTitle("App Store Connect")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    AsyncButton("Connect", systemImage: "checkmark") {
                        if await vm.connect() {
                            store.bumpRefreshToken(for: .connect)
                            dismiss()
                        }
                    }
                    .disabled(vm.isConnecting)
                }
            }
            .task { await vm.load() }
        }
    }
}
