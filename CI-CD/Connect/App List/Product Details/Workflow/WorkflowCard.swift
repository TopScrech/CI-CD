import ScrechKit
import AppStoreConnect_Swift_SDK
import OSLog

struct WorkflowCard: View {
    @Environment(AppVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    @State private var renameVM = WorkflowRenameVM()
    @State private var isDeleting = false
    @State private var showDeleteError = false
    @State private var deleteError = ""

    private let workflow: CiWorkflow
    
    init(_ workflow: CiWorkflow) {
        self.workflow = workflow
    }
    
    private var iconColor: Color {
        if let isEnabled = workflow.attributes?.isEnabled {
            isEnabled ? .green : .red
        } else {
            .gray
        }
    }
    
    var body: some View {
        @Bindable var renameVM = renameVM

        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(workflow.attributes?.name ?? "")
                
                if let description = workflow.attributes?.description, !description.isEmpty {
                    Text(description)
                        .secondary()
                        .footnote()
                }
            } icon: {
                Image(systemName: "server.rack")
                    .bold()
                    .foregroundStyle(iconColor)
                    .frame(width: 30)
            }
            .foregroundStyle(.foreground)
            
            if let actions = workflow.attributes?.actions {
                ForEach(actions) {
                    WorkflowActionCard($0)
                }
            }
        }
        .contextMenu {
            AsyncButton("Start build", systemImage: "play", action: startBuild)
            AsyncButton("Start clean build", systemImage: "play", action: startCleanBuild)

            Divider()

            Button("Rename", systemImage: "pencil") {
                renameVM.present(workflow)
            }
            .disabled(isDeleting || renameVM.isSaving)
            
            AsyncButton("Delete", systemImage: "trash", role: .destructive) {
                await deleteWorkflow()
            }
            .disabled(isDeleting || renameVM.isSaving)
        }
        .alert("Rename workflow", isPresented: $renameVM.isPresented) {
            TextField("Name", text: $renameVM.name)
            TextField("Description", text: $renameVM.description)

            Button("Cancel", role: .cancel) {}

            Button("Save") {
                Task {
                    await renameVM.save(workflow, appVM: vm, store: store)
                }
            }
            .disabled(!renameVM.canSave)
        }
        .alert("Could not rename workflow", isPresented: $renameVM.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(renameVM.errorMessage)
        }
        .alert("Could not delete workflow", isPresented: $showDeleteError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(deleteError)
        }
    }
    
    private func deleteWorkflow() async {
        guard !isDeleting else { return }
        isDeleting = true
        defer { isDeleting = false }

        do {
            try await vm.deleteWorkflow(workflow.id, store: store)
        } catch {
            deleteError = error.localizedDescription
            showDeleteError = true
        }
    }

    private func startBuild() async {
        if store.connectDemoMode {
            if let build = vm.builds.first {
                vm.builds.append(build)
            }
        } else {
            do {
                try await vm.startBuild(workflow.id, store: store)
            } catch {
                Logger().error("Failed to start build: \(error)")
            }
        }
    }
    
    private func startCleanBuild() async {
        if store.connectDemoMode {
            if let build = vm.builds.first {
                vm.builds.append(build)
            }
        } else {
            do {
                try await vm.startBuild(workflow.id, clean: true, store: store)
            } catch {
                Logger().error("Failed to start clean build: \(error)")
            }
        }
    }
}

#Preview {
    List {
        WorkflowCard(CiWorkflow.preview)
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
