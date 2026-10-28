import ScrechKit

@available(iOS 26, macOS 26, visionOS 26, *)
struct ConnectUsageSectionView: View {
    @Environment(ConnectUsageVM.self) private var vm

    var body: some View {
        if vm.plan != nil || vm.isLoading || vm.errorMessage != nil {
            Section {
                VStack(alignment: .leading) {
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
                            .footnote()
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }
}
