import ScrechKit

struct WorkflowEnvironmentSectionView: View {
    @Environment(WorkflowEnvironmentVM.self) private var vm
    @Environment(WorkflowEditorVM.self) private var editorVM
    @EnvironmentObject private var store: ValueStore

    var body: some View {
        @Bindable var vm = vm
        @Bindable var editorVM = editorVM

        Section("Environment") {
            if vm.isLoading || !vm.hasLoaded || editorVM.isRefreshing {
                LabeledContent("Xcode") {
                    ProgressView()
                        .accessibilityLabel("Loading Xcode versions")
                }

                LabeledContent("macOS") {
                    ProgressView()
                        .accessibilityLabel("Loading macOS versions")
                }
            } else {
                Picker("Xcode", selection: $vm.xcodeVersionID) {
                    if !vm.xcodeVersions.contains(where: { $0.id == vm.xcodeVersionID }) {
                        Text(vm.xcodeVersionID == nil ? "Select a version" : "Current version (unavailable)")
                            .tag(vm.xcodeVersionID)
                    }

                    WorkflowVersionOptionsView(options: vm.xcodeOptions, catalog: vm.xcodeOptions)
                }
                .disabled(vm.isLoading || vm.xcodeVersions.isEmpty)
                .onChange(of: vm.xcodeVersionID) {
                    // Refresh preserves the saved pair without selecting a replacement
                    if vm.hasChanges {
                        vm.selectCompatibleMacOSVersion()
                    }
                }

                Picker("macOS", selection: $vm.macOSVersionID) {
                    if !vm.compatibleMacOSVersions.contains(where: { $0.id == vm.macOSVersionID }) {
                        Text(vm.macOSVersionID == nil ? "Select a version" : "Current version (unavailable)")
                            .tag(vm.macOSVersionID)
                    }

                    WorkflowVersionOptionsView(options: vm.compatibleMacOSOptions, catalog: vm.macOSOptions)
                }
                .disabled(vm.isLoading || vm.compatibleMacOSVersions.isEmpty)

            }

            Toggle(isOn: $editorVM.isClean) {
                Text("Clean")
                Text("Xcode Cloud will not restore derived data or caches for your builds, which may take significantly longer as a result")
            }

            if let errorMessage = vm.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.secondary)

                AsyncButton("Retry", systemImage: "arrow.clockwise") {
                    await vm.load(store: store)
                }
            }
        }
    }
}
