import SwiftUI
import AppStoreConnect_Swift_SDK

@Observable
final class WorkflowEditorVM {
    var name: String
    var description: String
    var restrictEditing: Bool
    var isRefreshing = false
    var isSaving = false
    var showError = false
    var errorMessage = ""
    var errorTitle = ""

    private var originalName: String
    private var originalDescription: String
    private var originalRestrictEditing: Bool

    init(_ workflow: CiWorkflow) {
        let name = workflow.attributes?.name ?? ""
        let description = workflow.attributes?.description ?? ""
        let restrictEditing = workflow.attributes?.isLockedForEditing ?? false
        originalName = name
        originalDescription = description
        originalRestrictEditing = restrictEditing
        self.name = name
        self.description = description
        self.restrictEditing = restrictEditing
    }

    func refresh(from workflow: CiWorkflow) {
        let refreshedName = workflow.attributes?.name ?? ""
        let refreshedDescription = workflow.attributes?.description ?? ""
        let refreshedRestrictEditing = workflow.attributes?.isLockedForEditing ?? false

        if name == originalName {
            name = refreshedName
        }
        if description == originalDescription {
            description = refreshedDescription
        }
        if restrictEditing == originalRestrictEditing {
            restrictEditing = refreshedRestrictEditing
        }

        originalName = refreshedName
        originalDescription = refreshedDescription
        originalRestrictEditing = refreshedRestrictEditing
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSave: Bool {
        !isSaving && !isRefreshing && !trimmedName.isEmpty &&
        (trimmedName != originalName || description != originalDescription || restrictEditing != originalRestrictEditing)
    }
}
