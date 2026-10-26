import ScrechKit

@available(iOS 26, macOS 26, visionOS 26, *)
struct ConnectUsageSectionView: View {
    @Environment(ConnectUsageVM.self) private var vm
    @EnvironmentObject private var store: ValueStore

    var body: some View {
        if vm.plan != nil || vm.isLoading || vm.errorMessage != nil {
            Section {
                if let plan = vm.plan {
                    ConnectUsageCardView(plan: plan)
                } else if vm.isLoading {
                    HStack {
                        Text("Quota")
                        Spacer()
                        ProgressView()
                    }
                }
                if let errorMessage = vm.errorMessage {
                    Text(errorMessage)
                        .secondary()
                    if let accountID = store.connectAccount?.id {
                        AsyncButton("Retry", systemImage: "arrow.clockwise") {
                            await vm.load(accountID: accountID)
                        }
                    }
                }
            }
        }
    }
}
