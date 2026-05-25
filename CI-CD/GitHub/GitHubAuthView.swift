import SwiftData
import SwiftUI

struct GitHubAuthView: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(
        filter: #Predicate<ProviderAccount> { $0.providerRawValue == "github" },
        sort: \ProviderAccount.createdAt,
        order: .reverse
    ) private var accounts: [ProviderAccount]
    
    private let showsAccountPicker: Bool
    private let onDismiss: () async -> Void
    
    init(showsAccountPicker: Bool = true, onDismiss: @escaping () async -> Void = {}) {
        self.showsAccountPicker = showsAccountPicker
        self.onDismiss = onDismiss
    }
    
    private var selectedAccount: ProviderAccount? {
        if let selectedID = store.githubAccount?.id,
           let match = accounts.first(where: { $0.id == selectedID }) {
            return match
        }
        
        return accounts.first
    }
    
    var body: some View {
        List {
            demoSection
            
            if !store.githubDemoMode {
                if showsAccountPicker {
                    accountsSection
                }
                
                if let account = selectedAccount {
                    AccountNameSection(account: account)
                    credentialsSection(account)
                } else {
                    ContentUnavailableView("No GitHub accounts", systemImage: "person.crop.circle.badge.plus")
                }
            } else {
                Section {
                    Button("Save", action: save)
                }
            }
            
            if !store.githubDemoMode, selectedAccount != nil {
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
            store.refreshSelection(for: .github)
        }
    }
    
    private var accountsSection: some View {
        Section("Accounts") {
            if accounts.isEmpty {
                Button("Add account", systemImage: "plus", action: addAccount)
            } else {
                ForEach(accounts) { account in
                    Button {
                        store.selectAccount(account.id, provider: .github)
                    } label: {
                        HStack {
                            Text(account.effectiveName)
                            
                            Spacer()
                            
                            if store.githubAccount?.id == account.id {
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
        
        return Section {
            TextField("https://api.github.com", text: $account.githubAPIBaseURL)
                .textContentType(.URL)
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .onChange(of: account.githubAPIBaseURL, account.touch)
            
            TextField("Owner or organization", text: $account.githubOwner)
                .autocorrectionDisabled()
                .onChange(of: account.githubOwner, account.touch)
            
            SecureField("Personal access token", text: $account.githubToken)
                .textContentType(.password)
                .autocorrectionDisabled()
                .onChange(of: account.githubToken, account.touch)
        } header: {
            Text("Credentials")
        } footer: {
            Text("Use a token with repository access and Actions permissions. Leave owner blank to show repositories available to the authenticated user")
        }
    }
    
    private var demoSection: some View {
        Section {
            Toggle("Demo mode", isOn: $store.githubDemoMode)
        }
    }
    
    private func ensureAccountSelection() {
        guard !accounts.isEmpty else {
            store.selectAccount(nil, provider: .github)
            return
        }
        
        if let selectedID = store.githubAccount?.id,
           accounts.contains(where: { $0.id == selectedID }) {
            return
        }
        
        store.selectAccount(accounts.first?.id, provider: .github)
    }
    
    private func addAccount() {
        let account = ProviderAccount(provider: .github)
        modelContext.insert(account)
        saveChanges(selecting: account.id)
    }
    
    private func deleteAccounts(at offsets: IndexSet) {
        let accountsToDelete = offsets.compactMap {
            accounts.indices.contains($0) ? accounts[$0] : nil
        }
        guard !accountsToDelete.isEmpty else { return }
        
        let deletingSelected = accountsToDelete.contains { $0.id == store.githubAccount?.id }
        let selectedID = store.githubAccount?.id
        
        accountsToDelete.forEach(modelContext.delete)
        
        saveChanges(selecting: deletingSelected ? nil : selectedID)
    }
    
    private func deleteAccount(_ account: ProviderAccount) {
        let deletingSelected = account.id == store.githubAccount?.id
        let selectedID = store.githubAccount?.id
        
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
            store.selectAccount(id, provider: .github)
        }
        
        store.refreshSelection(for: .github)
        store.bumpRefreshToken(for: .github)
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
    GitHubAuthView()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
        .modelContainer(PreviewModelContainer.inMemory)
}
