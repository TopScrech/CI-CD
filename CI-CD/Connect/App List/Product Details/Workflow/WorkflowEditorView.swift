import ScrechKit
import AppStoreConnect_Swift_SDK

struct WorkflowEditorView: View {
    @Environment(AppVM.self) private var appVM
    @EnvironmentObject private var store: ValueStore
    @Environment(\.dismiss) private var dismiss
    @State private var vm: WorkflowEditorVM

    private let workflow: CiWorkflow

    init(_ workflow: CiWorkflow) {
        self.workflow = workflow
        _vm = State(initialValue: WorkflowEditorVM(workflow))
    }

    var body: some View {
        @Bindable var vm = vm

        Form {
            Section("Name") {
                TextField("Name", text: $vm.name)
            }

            Section("Description") {
                TextField("Description", text: $vm.description, axis: .vertical)
                    .lineLimit(3...10)
            }
            
            Toggle(isOn: $vm.restrictEditing) {
                Text("Restrict Editing")
                Text("Only Admins and App Managers on your team will be able to make changes")
            }

            WorkflowEnvironmentSectionView()
                .environment(vm.environment)
                .environment(vm)

        }
        .disabled(vm.isSaving || vm.isRefreshing)
        .refreshableTask {
            await refresh()
        }
        .navigationTitle("Edit workflow")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if vm.isSaving {
                    ProgressView()
                        .accessibilityLabel("Saving changes")
                } else {
                    AsyncButton("Save", systemImage: "checkmark") {
                        await save()
                    }
                    .disabled(!vm.canSave)
                }
            }
            .preferredToolbarAxis(.verticalPreferred)
        }
        .alert(vm.errorTitle, isPresented: $vm.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage)
        }
    }

    private func refresh() async {
        guard !vm.isSaving, !vm.isRefreshing else { return }
        vm.isRefreshing = true
        defer { vm.isRefreshing = false }

        async let versions: () = vm.environment.load(store: store)

        do {
            let refreshed = try await appVM.fetchWorkflow(workflow.id, store: store)
            vm.refresh(from: refreshed)
        } catch is CancellationError {
            return
        } catch {
            vm.errorTitle = "Could not refresh workflow"
            vm.errorMessage = error.localizedDescription
            vm.showError = true
        }

        await versions
    }

    private func save() async {
        guard vm.canSave else { return }
        vm.isSaving = true
        defer { vm.isSaving = false }

        do {
            try await appVM.updateWorkflow(
                workflow,
                name: vm.trimmedName,
                description: vm.description,
                restrictEditing: vm.restrictEditing,
                isClean: vm.isClean,
                xcodeVersionID: vm.environment.hasChanges ? vm.environment.xcodeVersionID : nil,
                macOSVersionID: vm.environment.hasChanges ? vm.environment.macOSVersionID : nil,
                store: store
            )
            dismiss()
        } catch {
            vm.errorTitle = "Could not save workflow"
            vm.errorMessage = error.localizedDescription
            vm.showError = true
        }
    }
}
