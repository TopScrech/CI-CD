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
    
    @State private var lastObservedDemoAccountID: UUID?
    @State private var lastObservedDemoMode = false
    @State private var pendingDeleteAccounts: [ProviderAccount] = []
    @State private var pendingDeleteSelected = false
    @State private var showDeleteAlert = false

    private var selectedAccount: ProviderAccount? {
        if let selectedID = store.coolifyAccount?.id,
           let match = accounts.first(where: { $0.id == selectedID }) {
            return match
        }

        return accounts.first
    }
    
    var body: some View {
        List {
            accountsSection

            if let account = selectedAccount {
                credentialsSection(account)
                demoSection(account)
            } else {
                ContentUnavailableView("No Coolify accounts", systemImage: "person.crop.circle.badge.plus")
            }
            
            if selectedAccount != nil {
                Section {
                    Button("Save", action: save)
                }
            }
        }
        .animation(.default, value: accounts.count)
        .alert(deleteAlertTitle, isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive, action: confirmDeleteAccounts)
            Button("Cancel", role: .cancel, action: cancelDeleteAccounts)
        } message: {
            Text(deleteAlertMessage)
        }
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
                }
                .onDelete(perform: deleteAccounts)

                Button("Add account", systemImage: "plus", action: addAccount)
            }
        }
    }

    private func credentialsSection(_ account: ProviderAccount) -> some View {
        @Bindable var account = account

        return Section("Credentials") {
            TextField("Account name", text: $account.name)
                .autocorrectionDisabled()
                .onChange(of: account.name) {
                    account.touch()
                }

            TextField("https://coolify.example.com", text: $account.coolifyDomain)
                .textContentType(.URL)
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .onChange(of: account.coolifyDomain) {
                    account.touch()
                }

            TextField("API key", text: $account.coolifyAPIKey)
                .autocorrectionDisabled()
                .onChange(of: account.coolifyAPIKey) {
                    account.touch()
                }

            Button("Reset credentials", role: .destructive) {
                account.coolifyDomain = "https://coolify.example.com"
                account.coolifyAPIKey = ""
                saveChanges()
            }
        }
    }

    @ViewBuilder
    private func demoSection(_ account: ProviderAccount) -> some View {
        @Bindable var account = account

        Section {
            Toggle("Demo mode", isOn: $account.demoMode)
                .onChange(of: account.id) {
                    lastObservedDemoAccountID = account.id
                    lastObservedDemoMode = account.demoMode
                }
                .onChange(of: account.demoMode) {
                    guard lastObservedDemoAccountID == account.id else {
                        lastObservedDemoAccountID = account.id
                        lastObservedDemoMode = account.demoMode
                        return
                    }

                    guard lastObservedDemoMode != account.demoMode else {
                        return
                    }

                    lastObservedDemoMode = account.demoMode
                    saveChanges()
                }
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

        pendingDeleteAccounts = accountsToDelete
        pendingDeleteSelected = accountsToDelete.contains { $0.id == store.coolifyAccount?.id }
        showDeleteAlert = true
    }

    private var deleteAlertTitle: String {
        pendingDeleteAccounts.count == 1 ? "Delete account?" : "Delete accounts?"
    }

    private var deleteAlertMessage: String {
        let count = pendingDeleteAccounts.count
        if count == 1 {
            let name = pendingDeleteAccounts.first?.effectiveName ?? "this account"
            return "This will remove \(name)"
        }
        return "This will remove \(count) accounts"
    }

    private func confirmDeleteAccounts() {
        let deletingSelected = pendingDeleteSelected
        let selectedID = store.coolifyAccount?.id

        pendingDeleteAccounts.forEach(modelContext.delete)
        pendingDeleteAccounts = []
        pendingDeleteSelected = false

        saveChanges(selecting: deletingSelected ? nil : selectedID)
    }

    private func cancelDeleteAccounts() {
        pendingDeleteAccounts = []
        pendingDeleteSelected = false
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
