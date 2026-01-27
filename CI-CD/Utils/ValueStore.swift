import SwiftUI
import SwiftData

#if os(macOS)
import Combine
#endif

#if canImport(Appearance)
import Appearance
#endif

final class ValueStore: ObservableObject {
    @AppStorage("last_tab") var lastTab = HomeViewTab.connect
    @AppStorage("demo_mode") private var legacyConnectDemoMode = false
    @AppStorage("coolify_demo_mode") private var legacyCoolifyDemoMode = false
#if os(iOS)
    @AppStorage("show_status_bar") var showStatusBar = true
#endif
    
#if canImport(Appearance)
    @AppStorage("appearance") var appearance: Appearance = .system
#endif

    @AppStorage("selected_connect_account_id") private var selectedConnectAccountIDRaw = ""
    @AppStorage("selected_coolify_account_id") private var selectedCoolifyAccountIDRaw = ""
    @AppStorage("accounts_migrated_v1") private var accountsMigratedV1 = false

    private var modelContext: ModelContext?

    @Published private(set) var connectAccount: ConnectAccountSnapshot?
    @Published private(set) var coolifyAccount: CoolifyAccountSnapshot?
    @Published private(set) var connectRefreshToken = UUID()
    @Published private(set) var coolifyRefreshToken = UUID()

    var connectDemoMode: Bool {
        connectAccount?.demoMode == true
    }

    var coolifyDemoMode: Bool {
        coolifyAccount?.demoMode == true
    }

    var connectAuthorized: Bool {
        connectAccount?.isAuthorized == true
    }

    var coolifyAuthorized: Bool {
        coolifyAccount?.isAuthorized == true
    }

    var connectAccountTitle: String {
        connectAccount?.effectiveName ?? "Connect"
    }

    var coolifyAccountTitle: String {
        coolifyAccount?.effectiveName ?? "Coolify"
    }

    func configure(context: ModelContext) {
        modelContext = context
        migrateLegacyCredentialsIfNeeded()
        refreshSelections()
    }

    func refreshSelections() {
        refreshSelection(for: .connect)
        refreshSelection(for: .coolify)
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
        }
    }

    func selectAccount(_ id: UUID?, provider: AccountProvider) {
        switch provider {
        case .connect:
            selectedConnectAccountID = id
        case .coolify:
            selectedCoolifyAccountID = id
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

    private func migrateLegacyCredentialsIfNeeded() {
        guard !accountsMigratedV1, let modelContext else { return }

        let defaults = UserDefaults.standard

        let issuerID = defaults.string(forKey: "issuer") ?? ""
        let privateKey = defaults.string(forKey: "private_key") ?? ""
        let privateKeyID = defaults.string(forKey: "private_key_id") ?? ""

        let coolifyDomain = defaults.string(forKey: "coolify_domain") ?? "https://coolify.example.com"
        let coolifyAPIKey = defaults.string(forKey: "coolify_api_key") ?? ""

        var migratedConnectID: UUID?
        var migratedCoolifyID: UUID?

        if legacyConnectDemoMode || !issuerID.isEmpty || !privateKey.isEmpty || !privateKeyID.isEmpty {
            let connectAccount = ProviderAccount(
                provider: .connect,
                name: "",
                issuerID: issuerID,
                privateKey: privateKey,
                privateKeyID: privateKeyID,
                demoMode: legacyConnectDemoMode
            )
            modelContext.insert(connectAccount)
            migratedConnectID = connectAccount.id
        }

        if legacyCoolifyDemoMode || !coolifyDomain.isEmpty || !coolifyAPIKey.isEmpty {
            let coolifyAccount = ProviderAccount(
                provider: .coolify,
                name: "",
                coolifyDomain: coolifyDomain,
                coolifyAPIKey: coolifyAPIKey,
                demoMode: legacyCoolifyDemoMode
            )
            modelContext.insert(coolifyAccount)
            migratedCoolifyID = coolifyAccount.id
        }

        try? modelContext.save()

        legacyConnectDemoMode = false
        legacyCoolifyDemoMode = false

        if selectedConnectAccountID == nil, let migratedConnectID {
            selectedConnectAccountID = migratedConnectID
        }

        if selectedCoolifyAccountID == nil, let migratedCoolifyID {
            selectedCoolifyAccountID = migratedCoolifyID
        }

        accountsMigratedV1 = true
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

        if demoMode {
            return "Connect demo"
        }

        return issuerID.isEmpty ? "Connect account" : issuerID
    }

    var isAuthorized: Bool {
        demoMode || (!issuerID.isEmpty && !privateKey.isEmpty && !privateKeyID.isEmpty)
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

        if demoMode {
            return "Coolify demo"
        }

        return domain.isEmpty ? "Coolify account" : domain
    }

    var isAuthorized: Bool {
        demoMode || (!domain.isEmpty && !apiKey.isEmpty)
    }
}
