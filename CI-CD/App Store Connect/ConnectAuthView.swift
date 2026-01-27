import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct ConnectAuthView: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<ProviderAccount> { $0.providerRawValue == "connect" },
        sort: \ProviderAccount.createdAt,
        order: .reverse
    ) private var accounts: [ProviderAccount]
    
    private let onDismiss: () async -> Void
    
    init(onDismiss: @escaping () async -> Void = {}) {
        self.onDismiss = onDismiss
    }
    
    @State private var showPicker = false
    @State private var lastObservedDemoAccountID: UUID?
    @State private var lastObservedDemoMode = false
    @State private var pendingDeleteAccounts: [ProviderAccount] = []
    @State private var pendingDeleteSelected = false
    @State private var showDeleteAlert = false
    
    private var selectedAccount: ProviderAccount? {
        if let selectedID = store.connectAccount?.id,
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
                ContentUnavailableView("No Connect accounts", systemImage: "person.crop.circle.badge.plus")
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
            store.refreshSelection(for: .connect)
        }
        .fileImporter(
            isPresented: $showPicker,
            allowedContentTypes: [UTType(filenameExtension: "p8")!],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                processImportedFile(urls)
                
            case .failure(let error):
                Logger().error("Failed to pick file: \(error)")
            }
        }
    }

    private var accountsSection: some View {
        Section("Accounts") {
            if accounts.isEmpty {
                Button("Add account", systemImage: "plus", action: addAccount)
            } else {
                ForEach(accounts) { account in
                    Button {
                        store.selectAccount(account.id, provider: .connect)
                    } label: {
                        HStack {
                            Text(account.effectiveName)

                            Spacer()

                            if store.connectAccount?.id == account.id {
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

    @ViewBuilder
    private func credentialsSection(_ account: ProviderAccount) -> some View {
        @Bindable var account = account

        Section {
            TextField("Account name", text: $account.name)
                .autocorrectionDisabled()
                .onChange(of: account.name) {
                    account.touch()
                }

            HStack {
                TextField("Issuer ID", text: $account.issuerID)
                    .autocorrectionDisabled()
                    .onChange(of: account.issuerID) {
                        account.touch()
                    }
#if !os(macOS)
                    .textInputAutocapitalization(.none)
#endif
                PasteButton(payloadType: String.self) { paste in
                    if let issuer = paste.first, issuer.count == 36 {
                        account.issuerID = issuer
                    }
                }
            }

            TextEditor(text: $account.privateKey)
                .autocorrectionDisabled()
                .onChange(of: account.privateKey) {
                    account.touch()
                }
#if !os(macOS)
                .textInputAutocapitalization(.none)
#endif

            TextField("Private Key ID", text: $account.privateKeyID)
                .autocorrectionDisabled()
                .onChange(of: account.privateKeyID) {
                    account.touch()
                }
#if !os(macOS)
                .textInputAutocapitalization(.none)
#endif

            Button("Import from Files", systemImage: "document.badge.plus") {
                showPicker = true
            }
            .foregroundStyle(.foreground)

            Button("Reset credentials", role: .destructive) {
                account.issuerID = ""
                account.privateKey = ""
                account.privateKeyID = ""
                saveChanges()
            }
        } header: {
            Text("Credentials")
        } footer: {
            Text("You need an API key with the 'Admin' role from App Store Connect to start builds with external deployments. API keys with the 'Developer' role cannot be used for this")
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
            store.selectAccount(nil, provider: .connect)
            return
        }

        if let selectedID = store.connectAccount?.id,
           accounts.contains(where: { $0.id == selectedID }) {
            return
        }

        store.selectAccount(accounts.first?.id, provider: .connect)
    }
    
    private func addAccount() {
        let account = ProviderAccount(provider: .connect)
        modelContext.insert(account)
        saveChanges(selecting: account.id)
    }

    private func deleteAccounts(at offsets: IndexSet) {
        let accountsToDelete = offsets.compactMap { index in
            accounts.indices.contains(index) ? accounts[index] : nil
        }
        guard !accountsToDelete.isEmpty else { return }

        pendingDeleteAccounts = accountsToDelete
        pendingDeleteSelected = accountsToDelete.contains { $0.id == store.connectAccount?.id }
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
        let selectedID = store.connectAccount?.id

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
            store.selectAccount(id, provider: .connect)
        }

        store.refreshSelection(for: .connect)
        store.bumpRefreshToken(for: .connect)
    }

    private func accountModel(for id: UUID) -> ProviderAccount? {
        var descriptor = FetchDescriptor<ProviderAccount>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        return try? modelContext.fetch(descriptor).first
    }
    
    private func processImportedFile(_ urls: [URL]) {
        guard let url = urls.first, let account = selectedAccount else {
            return
        }

        if let privateKey = readP8File(url) {
            account.privateKey = privateKey
        }
            
        let keyId = url.lastPathComponent
            .replacing("AuthKey_", with: "")
            .replacing(".p8", with: "")
            
        account.privateKeyID = keyId
        saveChanges()
    }
    
    private func readP8File(_ url: URL) -> String? {
        let access = url.startAccessingSecurityScopedResource()
        
        defer {
            if access {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            let contents = try String(contentsOf: url, encoding: .utf8)
            
            let lines = contents
                .components(separatedBy: .newlines)
                .filter { line in
                    !line.trimmingCharacters(in: .whitespaces).isEmpty &&
                    line != "-----BEGIN PRIVATE KEY-----" &&
                    line != "-----END PRIVATE KEY-----"
                }
            
            return lines.joined()
        } catch {
            Logger().error("Failed to read file: \(error)")
            return nil
        }
    }
}

#Preview {
    ConnectAuthView()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
        .modelContainer(PreviewModelContainer.inMemory)
}
