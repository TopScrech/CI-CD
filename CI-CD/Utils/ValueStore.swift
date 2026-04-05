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

    @AppStorage("last_tab") var lastTab = HomeViewTab.connect
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
    private let defaults: UserDefaults

    @Published private(set) var connectAccount: ConnectAccountSnapshot?
    @Published private(set) var coolifyAccount: CoolifyAccountSnapshot?
    @Published private(set) var connectRefreshToken = UUID()
    @Published private(set) var coolifyRefreshToken = UUID()
    @Published var connectDemoMode = false {
        didSet {
            persistDemoMode(connectDemoMode, for: .connect, previousValue: oldValue)
        }
    }
    @Published var coolifyDemoMode = false {
        didSet {
            persistDemoMode(coolifyDemoMode, for: .coolify, previousValue: oldValue)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        connectDemoMode = defaults.bool(forKey: Self.connectDemoModeKey)
        coolifyDemoMode = defaults.bool(forKey: Self.coolifyDemoModeKey)
    }

    var connectAuthorized: Bool {
        connectAccount?.isAuthorized == true
    }

    var coolifyAuthorized: Bool {
        coolifyAccount?.isAuthorized == true
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

    func configure(context: ModelContext) {
        modelContext = context
        migrateLegacyCredentialsIfNeeded()
        migrateAccountDemoModesIfNeeded()
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

    private func persistDemoMode(_ enabled: Bool, for provider: AccountProvider, previousValue: Bool) {
        guard enabled != previousValue else { return }

        defaults.set(enabled, forKey: demoModeKey(for: provider))
        refreshSelection(for: provider)
        bumpRefreshToken(for: provider)
    }

    private func demoModeKey(for provider: AccountProvider) -> String {
        switch provider {
        case .connect:
            Self.connectDemoModeKey
        case .coolify:
            Self.coolifyDemoModeKey
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

    private func migrateAccountDemoModesIfNeeded() {
        guard let modelContext else { return }

        var didChangeAccounts = false

        let connectAccounts = accounts(for: .connect, in: modelContext)
        if connectAccounts.contains(where: \.demoMode) {
            connectDemoMode = true
            connectAccounts
                .filter(\.demoMode)
                .forEach {
                    $0.demoMode = false
                    $0.touch()
                    didChangeAccounts = true
                }
        }

        let coolifyAccounts = accounts(for: .coolify, in: modelContext)
        if coolifyAccounts.contains(where: \.demoMode) {
            coolifyDemoMode = true
            coolifyAccounts
                .filter(\.demoMode)
                .forEach {
                    $0.demoMode = false
                    $0.touch()
                    didChangeAccounts = true
                }
        }

        guard didChangeAccounts else { return }

        try? modelContext.save()
    }
}

struct ConnectAccountSnapshot: Identifiable, Equatable {
    let id: UUID
    let name: String
    let issuerID: String
    let privateKey: String
    let privateKeyID: String

    init(_ account: ProviderAccount) {
        id = account.id
        name = account.name
        issuerID = account.issuerID
        privateKey = account.privateKey
        privateKeyID = account.privateKeyID
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

    init(_ account: ProviderAccount) {
        id = account.id
        name = account.name
        domain = account.coolifyDomain
        apiKey = account.coolifyAPIKey
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
