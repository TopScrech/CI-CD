import SwiftData
import SwiftUI

struct AccountPickerMenu: View {
    @EnvironmentObject private var store: ValueStore
    
    @Query(
        filter: #Predicate<ProviderAccount> { $0.providerRawValue == "connect" },
        sort: \ProviderAccount.createdAt,
        order: .reverse
    ) private var connectAccounts: [ProviderAccount]
    
    @Query(
        filter: #Predicate<ProviderAccount> { $0.providerRawValue == "coolify" },
        sort: \ProviderAccount.createdAt,
        order: .reverse
    ) private var coolifyAccounts: [ProviderAccount]
    
    let showConnectAuth: () -> Void
    let showCoolifyAuth: () -> Void
    
    init(showConnectAuth: @escaping () -> Void, showCoolifyAuth: @escaping () -> Void) {
        self.showConnectAuth = showConnectAuth
        self.showCoolifyAuth = showCoolifyAuth
    }
    
    var body: some View {
        Menu {
            connectSection
            coolifySection
        } label: {
            Label(currentTitle, systemImage: "person.crop.circle")
        }
        .onAppear {
            store.refreshSelections()
        }
        .onChange(of: connectAccounts.map(\.id)) {
            store.refreshSelection(for: .connect)
        }
        .onChange(of: coolifyAccounts.map(\.id)) {
            store.refreshSelection(for: .coolify)
        }
    }
    
    private var currentTitle: String {
        switch store.lastTab {
        case .connect:
            store.connectAccountTitle
        case .coolify:
            store.coolifyAccountTitle
        }
    }
    
    private var connectSection: some View {
        Section(AccountProvider.connect.title) {
            if connectAccounts.isEmpty {
                Button("Add Connect account", action: showConnectAuth)
            } else {
                ForEach(connectAccounts) { account in
                    Button {
                        store.lastTab = .connect
                        store.selectAccount(account.id, provider: .connect)
                    } label: {
                        accountRowLabel(
                            name: account.effectiveName,
                            isSelected: store.connectAccount?.id == account.id
                        )
                    }
                }
                
                Button("Manage Connect accounts", action: showConnectAuth)
            }
        }
    }
    
    private var coolifySection: some View {
        Section(AccountProvider.coolify.title) {
            if coolifyAccounts.isEmpty {
                Button("Add Coolify account", action: showCoolifyAuth)
            } else {
                ForEach(coolifyAccounts) { account in
                    Button {
                        store.lastTab = .coolify
                        store.selectAccount(account.id, provider: .coolify)
                    } label: {
                        accountRowLabel(
                            name: account.effectiveName,
                            isSelected: store.coolifyAccount?.id == account.id
                        )
                    }
                }
                
                Button("Manage Coolify accounts", action: showCoolifyAuth)
            }
        }
    }
    
    private func accountRowLabel(name: String, isSelected: Bool) -> some View {
        HStack {
            Text(name)
            
            if isSelected {
                Spacer()
                Image(systemName: "checkmark")
            }
        }
    }
}
