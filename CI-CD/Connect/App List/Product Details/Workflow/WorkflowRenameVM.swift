import SwiftUI
import AppStoreConnect_Swift_SDK

@Observable
final class WorkflowRenameVM {
    var name = ""
    var description = ""
    var isPresented = false
    var isSaving = false
    var showError = false
    var errorMessage = ""

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSave: Bool {
        !isSaving && !trimmedName.isEmpty
    }

    func present(_ workflow: CiWorkflow) {
        name = workflow.attributes?.name ?? ""
        description = workflow.attributes?.description ?? ""
        isPresented = true
    }

    func save(_ workflow: CiWorkflow, appVM: AppVM, store: ValueStore) async {
        guard canSave else { return }
        isSaving = true
        defer { isSaving = false }

        do {
            try await appVM.renameWorkflow(workflow, name: trimmedName, description: description, store: store)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
