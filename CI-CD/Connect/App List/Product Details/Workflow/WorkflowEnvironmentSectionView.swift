import ScrechKit

struct WorkflowEnvironmentSectionView: View {
    @Environment(WorkflowEnvironmentVM.self) private var vm
    @Environment(WorkflowEditorVM.self) private var editorVM
    @EnvironmentObject private var store: ValueStore

    var body: some View {
        @Bindable var vm = vm
        @Bindable var editorVM = editorVM
        let isShowingProgress = vm.isLoading || !vm.hasLoaded || editorVM.isRefreshing

        Section("Environment") {
            WorkflowVersionPickerView(
                title: "Xcode",
                selection: $vm.xcodeVersionID,
                options: vm.xcodeOptions,
                catalog: vm.xcodeOptions,
                currentVersion: vm.xcodeAliasCurrentVersion,
                isLoading: isShowingProgress
            )
            .onChange(of: vm.xcodeVersionID) {
                // Refresh preserves the saved pair without selecting a replacement
                if vm.hasChanges {
                    vm.selectCompatibleMacOSVersion()
                }
            }

            WorkflowVersionPickerView(
                title: "macOS",
                selection: $vm.macOSVersionID,
                options: vm.compatibleMacOSOptions,
                catalog: vm.macOSOptions,
                currentVersion: vm.macOSAliasCurrentVersion,
                isLoading: isShowingProgress
            )

            Toggle(isOn: $editorVM.isClean) {
                Text("Clean")
                Text("Xcode Cloud will not restore derived data or caches for your builds, which may take significantly longer as a result")
            }

            if let errorMessage = vm.errorMessage {
                Text(errorMessage)
                    .secondary()

                AsyncButton("Retry", systemImage: "arrow.clockwise") {
                    await vm.load(store: store)
                }
            }
        }
    }
}
