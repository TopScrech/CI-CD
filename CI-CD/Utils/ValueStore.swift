import SwiftUI
import SwiftData

#if os(macOS)
import Combine
#endif

#if canImport(Appearance)
import Appearance
#endif

final class ValueStore: ObservableObject {
    private static let connectDemoModeKey = "demo_mode"
    private static let coolifyDemoModeKey = "coolify_demo_mode"
    private static let githubDemoModeKey = "github_demo_mode"

    @AppStorage("last_tab") var lastTab = HomeViewTab.connect
#if os(iOS)
    @AppStorage("show_status_bar") var showStatusBar = true
#endif
    
#if canImport(Appearance)
    @AppStorage("appearance") var appearance: Appearance = .system
#endif

    @AppStorage("selected_connect_account_id") private var selectedConnectAccountIDRaw = ""
    @AppStorage("selected_coolify_account_id") private var selectedCoolifyAccountIDRaw = ""
    @AppStorage("selected_github_account_id") private var selectedGitHubAccountIDRaw = ""
    @AppStorage("accounts_migrated_v1") private var accountsMigratedV1 = false
    @AppStorage("account_demo_modes_migrated_v2") private var accountDemoModesMigratedV2 = false

    private var modelContext: ModelContext?
    private let defaults: UserDefaults

    @Published private(set) var connectAccount: ConnectAccountSnapshot?
    @Published private(set) var coolifyAccount: CoolifyAccountSnapshot?
    @Published private(set) var githubAccount: GitHubAccountSnapshot?
    @Published private(set) var connectRefreshToken = UUID()
    @Published private(set) var coolifyRefreshToken = UUID()
    @Published private(set) var githubRefreshToken = UUID()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    var connectDemoMode: Bool {
        connectAccount?.demoMode == true
    }
    
    var coolifyDemoMode: Bool {
        coolifyAccount?.demoMode == true
    }
    
    var githubDemoMode: Bool {
        githubAccount?.demoMode == true
    }

    var connectAuthorized: Bool {
        connectAccount?.isAuthorized == true
    }

    var coolifyAuthorized: Bool {
        coolifyAccount?.isAuthorized == true
    }
    
    var githubAuthorized: Bool {
        githubAccount?.isAuthorized == true
    }

    var connectAccountTitle: String {
        if connectDemoMode {
            return String(localized: "Connect demo")
        }

        return connectAccount?.effectiveName ?? String(localized: "Connect")
    }

    var coolifyAccountTitle: String {
        if coolifyDemoMode {
            return String(localized: "Coolify demo")
        }

        return coolifyAccount?.effectiveName ?? String(localized: "Coolify")
    }
    
    var githubAccountTitle: String {
        if githubDemoMode {
            return String(localized: "GitHub demo")
        }
        
        return githubAccount?.effectiveName ?? String(localized: "GitHub")
    }

    func configure(context: ModelContext) {
        modelContext = context
        migrateLegacyCredentialsIfNeeded()
        migrateGlobalDemoModesIfNeeded()
        refreshSelections()
    }

    func refreshSelections() {
        refreshSelection(for: .connect)
        refreshSelection(for: .coolify)
        refreshSelection(for: .github)
    }

    func refreshSelection(for provider: AccountProvider) {
        guard let modelContext else { return }

        let accounts = accounts(for: provider, in: modelContext)
        let selectedAccount = selectedAccount(from: accounts, provider: provider)

        switch provider {
        case .connect:
            connectAccount = selectedAccount.map(ConnectAccountSnapshot.init)
            selectedConnectAccountID = selectedAccount?.id
        case .coolify:
            coolifyAccount = selectedAccount.map(CoolifyAccountSnapshot.init)
            selectedCoolifyAccountID = selectedAccount?.id
        case .github:
            githubAccount = selectedAccount.map(GitHubAccountSnapshot.init)
            selectedGitHubAccountID = selectedAccount?.id
        }
    }

    func selectAccount(_ id: UUID?, provider: AccountProvider) {
        switch provider {
        case .connect:
            selectedConnectAccountID = id
        case .coolify:
            selectedCoolifyAccountID = id
        case .github:
            selectedGitHubAccountID = id
        }

        refreshSelection(for: provider)
        bumpRefreshToken(for: provider)
    }

    func bumpRefreshToken(for provider: AccountProvider) {
        switch provider {
        case .connect:
            connectRefreshToken = UUID()
        case .coolify:
            coolifyRefreshToken = UUID()
        case .github:
            githubRefreshToken = UUID()
        }
    }

    private func accounts(for provider: AccountProvider, in context: ModelContext) -> [ProviderAccount] {
        var descriptor = FetchDescriptor<ProviderAccount>(
            predicate: #Predicate { $0.providerRawValue == provider.rawValue },
            sortBy: [
                SortDescriptor(\.createdAt, order: .reverse)
            ]
        )
        descriptor.fetchLimit = 200

        return (try? context.fetch(descriptor)) ?? []
    }

    private func selectedAccount(from accounts: [ProviderAccount], provider: AccountProvider) -> ProviderAccount? {
        let selectedID = selectedID(for: provider)

        if let selectedID, let match = accounts.first(where: { $0.id == selectedID }) {
            return match
        }

        return accounts.first
    }

    private func selectedID(for provider: AccountProvider) -> UUID? {
        switch provider {
        case .connect:
            return selectedConnectAccountID
        case .coolify:
            return selectedCoolifyAccountID
        case .github:
            return selectedGitHubAccountID
        }
    }

    private var selectedConnectAccountID: UUID? {
        get { UUID(uuidString: selectedConnectAccountIDRaw) }
        set { selectedConnectAccountIDRaw = newValue?.uuidString ?? "" }
    }

    private var selectedCoolifyAccountID: UUID? {
        get { UUID(uuidString: selectedCoolifyAccountIDRaw) }
        set { selectedCoolifyAccountIDRaw = newValue?.uuidString ?? "" }
    }
    
    private var selectedGitHubAccountID: UUID? {
        get { UUID(uuidString: selectedGitHubAccountIDRaw) }
        set { selectedGitHubAccountIDRaw = newValue?.uuidString ?? "" }
    }

    private func migrateLegacyCredentialsIfNeeded() {
        guard !accountsMigratedV1, let modelContext else { return }

        let issuerID = defaults.string(forKey: "issuer") ?? ""
        let privateKey = defaults.string(forKey: "private_key") ?? ""
        let privateKeyID = defaults.string(forKey: "private_key_id") ?? ""

        let coolifyDomain = defaults.string(forKey: "coolify_domain") ?? "https://coolify.example.com"
        let coolifyAPIKey = defaults.string(forKey: "coolify_api_key") ?? ""

        var migratedConnectID: UUID?
        var migratedCoolifyID: UUID?

        if !issuerID.isEmpty || !privateKey.isEmpty || !privateKeyID.isEmpty {
            let connectAccount = ProviderAccount(
                provider: .connect,
                name: "",
                issuerID: issuerID,
                privateKey: privateKey,
                privateKeyID: privateKeyID
            )
            modelContext.insert(connectAccount)
            migratedConnectID = connectAccount.id
        }

        if !coolifyAPIKey.isEmpty || coolifyDomain != "https://coolify.example.com" {
            let coolifyAccount = ProviderAccount(
                provider: .coolify,
                name: "",
                coolifyDomain: coolifyDomain,
                coolifyAPIKey: coolifyAPIKey
            )
            modelContext.insert(coolifyAccount)
            migratedCoolifyID = coolifyAccount.id
        }

        try? modelContext.save()

        if selectedConnectAccountID == nil, let migratedConnectID {
            selectedConnectAccountID = migratedConnectID
        }

        if selectedCoolifyAccountID == nil, let migratedCoolifyID {
            selectedCoolifyAccountID = migratedCoolifyID
        }

        accountsMigratedV1 = true
    }

    private func migrateGlobalDemoModesIfNeeded() {
        guard !accountDemoModesMigratedV2, let modelContext else { return }
        
        migrateGlobalDemoModeIfNeeded(defaults.bool(forKey: Self.connectDemoModeKey), provider: .connect, in: modelContext)
        migrateGlobalDemoModeIfNeeded(defaults.bool(forKey: Self.coolifyDemoModeKey), provider: .coolify, in: modelContext)
        migrateGlobalDemoModeIfNeeded(defaults.bool(forKey: Self.githubDemoModeKey), provider: .github, in: modelContext)
        
        try? modelContext.save()
        accountDemoModesMigratedV2 = true
    }
    
    private func migrateGlobalDemoModeIfNeeded(_ enabled: Bool, provider: AccountProvider, in context: ModelContext) {
        guard enabled else { return }
        
        let existingAccounts = accounts(for: provider, in: context)
        let account = selectedAccount(from: existingAccounts, provider: provider) ?? ProviderAccount(
            provider: provider,
            name: String(localized: "\(provider.title) demo"),
            demoMode: true
        )
        
        if existingAccounts.isEmpty {
            context.insert(account)
            selectAccount(account.id, provider: provider)
        }
        
        account.demoMode = true
        account.touch()
    }
}

struct ConnectAccountSnapshot: Identifiable, Equatable {
    let id: UUID
    let name: String
    let issuerID: String
    let privateKey: String
    let privateKeyID: String
    let demoMode: Bool

    init(_ account: ProviderAccount) {
        id = account.id
        name = account.name
        issuerID = account.issuerID
        privateKey = account.privateKey
        privateKeyID = account.privateKeyID
        demoMode = account.demoMode
    }

    var effectiveName: String {
        if !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name
        }

        return issuerID.isEmpty ? String(localized: "Connect account") : issuerID
    }

    var isAuthorized: Bool {
        !issuerID.isEmpty && !privateKey.isEmpty && !privateKeyID.isEmpty
    }
}

struct CoolifyAccountSnapshot: Identifiable, Equatable {
    let id: UUID
    let name: String
    let domain: String
    let apiKey: String
    let demoMode: Bool

    init(_ account: ProviderAccount) {
        id = account.id
        name = account.name
        domain = account.coolifyDomain
        apiKey = account.coolifyAPIKey
        demoMode = account.demoMode
    }

    var effectiveName: String {
        if !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name
        }

        return domain.isEmpty ? String(localized: "Coolify account") : domain
    }

    var isAuthorized: Bool {
        !domain.isEmpty && !apiKey.isEmpty
    }
}

struct GitHubAccountSnapshot: Identifiable, Equatable {
    let id: UUID
    let name: String
    let apiBaseURL: String
    let token: String
    let owner: String
    let demoMode: Bool
    
    init(_ account: ProviderAccount) {
        id = account.id
        name = account.name
        apiBaseURL = account.githubAPIBaseURL
        token = account.githubToken
        owner = account.githubOwner
        demoMode = account.demoMode
    }
    
    var effectiveName: String {
        if !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name
        }
        
        return owner.isEmpty ? String(localized: "GitHub account") : owner
    }
    
    var isAuthorized: Bool {
        !apiBaseURL.isEmpty && !token.isEmpty
    }
}
