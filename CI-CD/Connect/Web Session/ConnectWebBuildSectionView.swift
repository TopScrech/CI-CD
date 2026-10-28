import ScrechKit
import ASC

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
struct ConnectWebBuildSectionView: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.connectProductID) private var productID
    @Environment(ConnectWebBuildVM.self) private var vm

    let build: CiBuildRun

    var body: some View {
        Section {
            if let summary = vm.summary {
                if let xcode = summary.xcode, !xcode.isEmpty {
                    LabeledContent("Xcode") {
                        Text(xcode)
                            .secondary()
                    }
                }
                if let macOS = summary.macOS, !macOS.isEmpty {
                    LabeledContent("macOS") {
                        Text(macOS)
                            .secondary()
                    }
                }
                if let duration = summary.duration {
                    LabeledContent("Duration") {
                        Text(Duration.seconds(duration), format: .units(allowed: [.hours, .minutes, .seconds], width: .abbreviated))
                    }
                } else {
                    BuildTimingView(build: build)
                }
                if let usage = summary.usage {
                    LabeledContent("Usage time") {
                        Text(Duration.seconds(usage), format: .units(allowed: [.hours, .minutes, .seconds], width: .abbreviated))
                    }
                }
            } else {
                BuildTimingView(build: build)
            }

            if !vm.isLoading, let errorMessage = vm.errorMessage {
                Text(errorMessage)
                    .secondary()
                AsyncButton("Retry", systemImage: "arrow.clockwise", action: load)
                if vm.requiresSignIn, let accountID = store.connectAccount?.id {
                    ConnectWebSignInButton(accountID: accountID, isReconnect: true)
                }
            } else if !vm.isLoading, vm.summary == nil, !store.connectDemoMode {
                if let accountID = store.connectAccount?.id {
                    ConnectWebSignInButton(accountID: accountID)
                }
            }
        } header: {
            Text("Environment")
                .task(id: "\(store.connectAccount?.id.uuidString ?? "").\(productID ?? "").\(build.id).\(store.connectDemoMode).\(store.connectRefreshToken)") {
                    await load()
                }
        }
    }

    private func load() async {
        guard let accountID = store.connectAccount?.id, !store.connectDemoMode else { return }
        await vm.load(accountID: accountID, productID: productID, buildID: build.id, buildNumber: build.attributes?.number)
    }
}
