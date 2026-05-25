import ScrechKit
import SwiftData

struct PanelSidebarAccountsSection: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.modelContext) private var modelContext
    
    let onSelect: (HomeViewTab) -> Void
    
    @State private var managementDestination: AccountProvider?
    
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
                        deleteAccount(account)
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
            }
        }
    }
    
    private func isSelected(_ account: ProviderAccount) -> Bool {
        switch account.provider {
        case .connect:
            store.lastTab == .connect && store.connectAccount?.id == account.id
        case .coolify:
            store.lastTab == .coolify && store.coolifyAccount?.id == account.id
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
    
    private func deleteAccount(_ account: ProviderAccount) {
        let provider = account.provider
        modelContext.delete(account)
        try? modelContext.save()
        store.refreshSelection(for: provider)
        store.bumpRefreshToken(for: provider)
    }
    
    private func destination(for provider: AccountProvider) -> AccountProvider { provider }
}
