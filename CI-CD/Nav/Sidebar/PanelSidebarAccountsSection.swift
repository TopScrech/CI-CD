import ScrechKit
import SwiftData

struct PanelSidebarAccountsSection: View {
    @EnvironmentObject private var store: ValueStore
    
    @Query(sort: \ProviderAccount.createdAt, order: .reverse) private var accounts: [ProviderAccount]
    
    var body: some View {
        if !accounts.isEmpty {
            VStack(alignment: .leading, spacing: 3) {
                Text("Accounts")
                    .caption(.semibold)
                    .secondary()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                
                ForEach(accounts) { account in
                    PanelSidebarAccountRow(account: account, isSelected: isSelected(account)) {
                        selectAccount(account)
                    }
                }
            }
            .onAppear {
                store.refreshSelections()
            }
            .onChange(of: accounts.map(\.id)) { _, _ in
                store.refreshSelections()
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
        store.lastTab = account.provider.homeViewTab
        store.selectAccount(account.id, provider: account.provider)
    }
}
