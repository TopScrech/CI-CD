import SwiftData
import SwiftUI

struct CoolifyAuthView: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(
        filter: #Predicate<ProviderAccount> { $0.providerRawValue == "coolify" },
        sort: \ProviderAccount.createdAt,
        order: .reverse
    ) private var accounts: [ProviderAccount]
    
    private let onDismiss: () async -> Void
    
    init(onDismiss: @escaping () async -> Void = {}) {
        self.onDismiss = onDismiss
    }
    
    private var selectedAccount: ProviderAccount? {
        if let selectedID = store.coolifyAccount?.id,
           let match = accounts.first(where: { $0.id == selectedID }) {
            return match
        }
        
        return accounts.first
    }
    
    var body: some View {
        List {
            demoSection
            
            if !store.coolifyDemoMode {
                accountsSection

                if let account = selectedAccount {
                    credentialsSection(account)
                } else {
                    ContentUnavailableView("No Coolify accounts", systemImage: "person.crop.circle.badge.plus")
                }
            } else {
                Section {
                    Button("Save", action: save)
                }
            }

            if !store.coolifyDemoMode, selectedAccount != nil {
                Section {
                    Button("Save", action: save)
                }
            }
        }
        .animation(.default, value: accounts.count)
        .onAppear {
            ensureAccountSelection()
        }
        .onChange(of: accounts.map(\.id)) {
            ensureAccountSelection()
            store.refreshSelection(for: .coolify)
        }
    }
    
    private var accountsSection: some View {
        Section("Accounts") {
            if accounts.isEmpty {
                Button("Add account", systemImage: "plus", action: addAccount)
            } else {
                ForEach(accounts) { account in
                    Button {
                        store.selectAccount(account.id, provider: .coolify)
                    } label: {
                        HStack {
                            Text(account.effectiveName)
                            
                            Spacer()
                            
                            if store.coolifyAccount?.id == account.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .tint(.primary)
                    .contextMenu {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            deleteAccount(account)
                        }
                    }
                }
                .onDelete(perform: deleteAccounts)
                
                Button("Add account", systemImage: "plus", action: addAccount)
            }
        }
    }
    
    private func credentialsSection(_ account: ProviderAccount) -> some View {
        @Bindable var account = account
        
        return Section("Credentials") {
            TextField("Account name (optional)", text: $account.name)
                .autocorrectionDisabled()
                .onChange(of: account.name) {
                    account.touch()
                }
            
            TextField("https://coolify.example.com", text: $account.coolifyDomain)
                .textContentType(.URL)
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .onChange(of: account.coolifyDomain, account.touch)
            
            TextField("API key", text: $account.coolifyAPIKey)
                .autocorrectionDisabled()
                .onChange(of: account.coolifyAPIKey, account.touch)
        }
    }
    
    private var demoSection: some View {
        Section {
            Toggle("Demo mode", isOn: $store.coolifyDemoMode)
        }
    }
    
    private func ensureAccountSelection() {
        guard !accounts.isEmpty else {
            store.selectAccount(nil, provider: .coolify)
            return
        }
        
        if let selectedID = store.coolifyAccount?.id,
           accounts.contains(where: { $0.id == selectedID }) {
            return
        }
        
        store.selectAccount(accounts.first?.id, provider: .coolify)
    }
    
    private func addAccount() {
        let account = ProviderAccount(provider: .coolify)
        modelContext.insert(account)
        saveChanges(selecting: account.id)
    }
    
    private func deleteAccounts(at offsets: IndexSet) {
        let accountsToDelete = offsets.compactMap { index in
            accounts.indices.contains(index) ? accounts[index] : nil
        }
        guard !accountsToDelete.isEmpty else { return }
        
        let deletingSelected = accountsToDelete.contains { $0.id == store.coolifyAccount?.id }
        let selectedID = store.coolifyAccount?.id
        
        accountsToDelete.forEach(modelContext.delete)
        
        saveChanges(selecting: deletingSelected ? nil : selectedID)
    }

    private func deleteAccount(_ account: ProviderAccount) {
        let deletingSelected = account.id == store.coolifyAccount?.id
        let selectedID = store.coolifyAccount?.id

        modelContext.delete(account)

        saveChanges(selecting: deletingSelected ? nil : selectedID)
    }
    
    private func save() {
        saveChanges()
        
        Task {
            await onDismiss()
        }
        
        dismiss()
    }
    
    private func saveChanges(selecting id: UUID? = nil) {
        let accountToTouch: ProviderAccount?
        
        if let id {
            accountToTouch = accountModel(for: id) ?? selectedAccount
        } else {
            accountToTouch = selectedAccount
        }
        
        accountToTouch?.touch()
        try? modelContext.save()
        
        if let id {
            store.selectAccount(id, provider: .coolify)
        }
        
        store.refreshSelection(for: .coolify)
        store.bumpRefreshToken(for: .coolify)
    }
    
    private func accountModel(for id: UUID) -> ProviderAccount? {
        var descriptor = FetchDescriptor<ProviderAccount>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        
        return try? modelContext.fetch(descriptor).first
    }
}

#Preview {
    CoolifyAuthView()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
        .modelContainer(PreviewModelContainer.inMemory)
}
