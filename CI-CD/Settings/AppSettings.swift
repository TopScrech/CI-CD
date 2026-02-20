import SwiftData
import SwiftUI

#if canImport(Appearance)
import Appearance
#endif

struct AppSettings: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.modelContext) private var modelContext
    
    @State private var showConnectAuth = false
    @State private var showCoolifyAuth = false
    @State private var lastObservedConnectDemoAccountID: UUID?
    @State private var lastObservedConnectDemoMode = false
    @State private var lastObservedCoolifyDemoAccountID: UUID?
    @State private var lastObservedCoolifyDemoMode = false
    
    var body: some View {
        List {
#if canImport(Appearance)
            Section {
                AppearancePicker($store.appearance)
            }
#endif
            Section {
                connectDemoRow()
                coolifyDemoRow()
            }
            
            AppSettingsFeedback()
#if DEBUG
            AppSettingsDebug()
#endif
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Settings")
        .ornamentDismissButton()
        .foregroundStyle(.foreground)
        .sheet($showConnectAuth) {
            ConnectAuthView()
        }
        .sheet($showCoolifyAuth) {
            CoolifyAuthView()
        }
    }
    
    @ViewBuilder
    private func connectDemoRow() -> some View {
        if let account = connectAccountModel {
            @Bindable var account = account
            
            Toggle(isOn: $account.demoMode) {
                Label("Connect demo", systemImage: "hammer")
            }
            .onChange(of: account.id) {
                lastObservedConnectDemoAccountID = account.id
                lastObservedConnectDemoMode = account.demoMode
            }
            .onChange(of: account.demoMode) {
                guard lastObservedConnectDemoAccountID == account.id else {
                    lastObservedConnectDemoAccountID = account.id
                    lastObservedConnectDemoMode = account.demoMode
                    return
                }
                
                guard lastObservedConnectDemoMode != account.demoMode else {
                    return
                }
                
                lastObservedConnectDemoMode = account.demoMode
                saveDemoChanges(for: .connect)
            }
        } else {
            Button("Manage Connect accounts") {
                showConnectAuth = true
            }
        }
    }
    
    @ViewBuilder
    private func coolifyDemoRow() -> some View {
        if let account = coolifyAccountModel {
            @Bindable var account = account
            
            Toggle(isOn: $account.demoMode) {
                Label("Coolify demo", systemImage: "cloud")
            }
            .onChange(of: account.id) {
                lastObservedCoolifyDemoAccountID = account.id
                lastObservedCoolifyDemoMode = account.demoMode
            }
            .onChange(of: account.demoMode) {
                guard lastObservedCoolifyDemoAccountID == account.id else {
                    lastObservedCoolifyDemoAccountID = account.id
                    lastObservedCoolifyDemoMode = account.demoMode
                    return
                }
                
                guard lastObservedCoolifyDemoMode != account.demoMode else {
                    return
                }
                
                lastObservedCoolifyDemoMode = account.demoMode
                saveDemoChanges(for: .coolify)
            }
        } else {
            Button("Manage Coolify accounts") {
                showCoolifyAuth = true
            }
        }
    }
    
    private func saveDemoChanges(for provider: AccountProvider) {
        accountModel(for: selectedAccountID(for: provider))?.touch()
        try? modelContext.save()
        store.refreshSelection(for: provider)
        store.bumpRefreshToken(for: provider)
    }
    
    private var connectAccountModel: ProviderAccount? {
        accountModel(for: store.connectAccount?.id)
    }
    
    private var coolifyAccountModel: ProviderAccount? {
        accountModel(for: store.coolifyAccount?.id)
    }
    
    private func selectedAccountID(for provider: AccountProvider) -> UUID? {
        switch provider {
        case .connect: store.connectAccount?.id
        case .coolify: store.coolifyAccount?.id
        }
    }
    
    private func accountModel(for id: UUID?) -> ProviderAccount? {
        guard let id else { return nil }
        
        var descriptor = FetchDescriptor<ProviderAccount>(
            predicate: #Predicate { $0.id == id }
        )
        
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first
    }
}

#Preview {
    NavigationStack {
        AppSettings()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
