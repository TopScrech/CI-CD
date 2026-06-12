import ScrechKit
import SwiftData

struct PanelSidebarAccountsSection: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.modelContext) private var modelContext
    
    let onSelect: (HomeViewTab) -> Void
    
    @State private var managementDestination: AccountProvider?
    @State private var deletionRequest: PanelSidebarAccountDeletionRequest?
    @State private var showsDeletionAlert = false
    
    @Query(sort: \ProviderAccount.createdAt, order: .reverse) private var accounts: [ProviderAccount]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Accounts")
                .caption(.semibold)
                .secondary()
                .padding(.horizontal, 10)
                .padding(.vertical, 2)
            
            if !accounts.isEmpty {
                ForEach(accounts) { account in
                    PanelSidebarAccountRow(account: account, isSelected: isSelected(account)) {
                        selectAccount(account)
                    } edit: {
                        editAccount(account)
                    } delete: {
                        requestAccountDeletion(account)
                    }
                }
            }
        }
        .onAppear {
            store.refreshSelections()
        }
        .onChange(of: accounts.map(\.id)) { _, _ in
            store.refreshSelections()
        }
        .sheet(item: $managementDestination) {
            switch $0 {
            case .connect:
                NavigationStack {
                    ConnectAuthView(showsAccountPicker: false)
                }
            case .coolify:
                NavigationStack {
                    CoolifyAuthView(showsAccountPicker: false)
                }
            case .github:
                NavigationStack {
                    GitHubAuthView(showsAccountPicker: false)
                }
            }
        }
        .alert("Delete account?", isPresented: $showsDeletionAlert) {
            Button("Cancel", role: .cancel) {
                deletionRequest = nil
            }
            Button("Delete", role: .destructive) {
                if let deletionRequest {
                    deleteAccount(id: deletionRequest.id)
                }
            }
        } message: {
            if let deletionRequest {
                Text("This will remove \(deletionRequest.name) from CI/CD")
            }
        }
    }
    
    private func isSelected(_ account: ProviderAccount) -> Bool {
        switch account.provider {
        case .connect:
            store.lastTab == .connect && store.connectAccount?.id == account.id
        case .coolify:
            store.lastTab == .coolify && store.coolifyAccount?.id == account.id
        case .github:
            store.lastTab == .github && store.githubAccount?.id == account.id
        }
    }
    
    private func selectAccount(_ account: ProviderAccount) {
        store.selectAccount(account.id, provider: account.provider)
        onSelect(account.provider.homeViewTab)
    }
    
    private func editAccount(_ account: ProviderAccount) {
        selectAccount(account)
        managementDestination = destination(for: account.provider)
    }
    
    private func requestAccountDeletion(_ account: ProviderAccount) {
        deletionRequest = PanelSidebarAccountDeletionRequest(account)
        showsDeletionAlert = true
    }
    
    private func deleteAccount(id: UUID) {
        guard let account = accounts.first(where: { $0.id == id }) else { return }
        
        let provider = account.provider
        modelContext.delete(account)
        try? modelContext.save()
        deletionRequest = nil
        store.refreshSelection(for: provider)
        store.bumpRefreshToken(for: provider)
    }
    
    private func destination(for provider: AccountProvider) -> AccountProvider { provider }
}
