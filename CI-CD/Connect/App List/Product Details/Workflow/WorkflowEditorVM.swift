import SwiftUI
import ASC

@Observable
final class WorkflowEditorVM {
    let environment: WorkflowEnvironmentVM
    var name: String
    var description: String
    var restrictEditing: Bool
    var isClean: Bool
    var isRefreshing = false
    var isSaving = false
    var showError = false
    var errorMessage = ""
    var errorTitle = ""

    private var originalName: String
    private var originalDescription: String
    private var originalRestrictEditing: Bool
    private var originalIsClean: Bool

    init(_ workflow: CiWorkflow) {
        environment = WorkflowEnvironmentVM(workflow)
        let name = workflow.attributes?.name ?? ""
        let description = workflow.attributes?.description ?? ""
        let restrictEditing = workflow.attributes?.isLockedForEditing ?? false
        let isClean = workflow.attributes?.isClean ?? false
        originalName = name
        originalDescription = description
        originalRestrictEditing = restrictEditing
        originalIsClean = isClean
        self.name = name
        self.description = description
        self.restrictEditing = restrictEditing
        self.isClean = isClean
    }

    func refresh(from workflow: CiWorkflow) {
        environment.refresh(from: workflow)
        let refreshedName = workflow.attributes?.name ?? ""
        let refreshedDescription = workflow.attributes?.description ?? ""
        let refreshedRestrictEditing = workflow.attributes?.isLockedForEditing ?? false
        let refreshedIsClean = workflow.attributes?.isClean ?? false

        if name == originalName {
            name = refreshedName
        }
        if description == originalDescription {
            description = refreshedDescription
        }
        if restrictEditing == originalRestrictEditing {
            restrictEditing = refreshedRestrictEditing
        }

        if isClean == originalIsClean {
            isClean = refreshedIsClean
        }

        originalIsClean = refreshedIsClean
        originalName = refreshedName
        originalDescription = refreshedDescription
        originalRestrictEditing = refreshedRestrictEditing
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSave: Bool {
        !isSaving && !isRefreshing && !environment.isLoading && environment.canSave && !trimmedName.isEmpty &&
        (trimmedName != originalName || description != originalDescription || restrictEditing != originalRestrictEditing || isClean != originalIsClean || environment.hasChanges)
    }
}
