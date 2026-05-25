import ScrechKit
import SwiftData

struct PanelSidebarAddAccountButton: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.modelContext) private var modelContext
    
    @State private var managementDestination: AccountProvider?
    
    var body: some View {
        Menu {
            Button(AccountProvider.connect.title, systemImage: AccountProvider.connect.systemImage) {
                addAccount(.connect)
            }
            
            Button(AccountProvider.coolify.title, systemImage: AccountProvider.coolify.systemImage) {
                addAccount(.coolify)
            }
        } label: {
            HStack(spacing: 10) {
                Text("Add account")
                    .subheadline(.semibold)
                
                Spacer(minLength: 0)
                
                Image(systemName: "plus")
                    .subheadline(.semibold)
                    .frame(width: 22)
            }
            .foregroundStyle(.foreground)
//            .padding(.vertical, 7)
            .padding(.horizontal, 10)
            .contentShape(.rect)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
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
    
    private func addAccount(_ provider: AccountProvider) {
        let account = ProviderAccount(provider: provider)
        modelContext.insert(account)
        try? modelContext.save()
        store.lastTab = provider.homeViewTab
        store.selectAccount(account.id, provider: provider)
        managementDestination = provider
    }
}
