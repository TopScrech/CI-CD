import Foundation

struct PanelSidebarAccountDeletionRequest: Identifiable {
    let id: UUID
    let name: String
    
    init(_ account: ProviderAccount) {
        id = account.id
        name = account.effectiveName
    }
}
