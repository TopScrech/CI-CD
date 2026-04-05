import ScrechKit
import SwiftData

struct DebugSettings: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.modelContext) private var modelContext
    
    @State private var sheetAuthConnect = false
    @State private var sheetAuthCoolify = false
    
    var body: some View {
        List {
            Section {
#if os(iOS)
                Toggle("Status bar", isOn: $store.showStatusBar)
#endif
            }
            
            Section("Coolify") {
                Button("Coolify credentials") {
                    sheetAuthCoolify = true
                }
                .sheet($sheetAuthCoolify) {
                    CoolifyAuthView()
                }
                
                Button(String("Copy Coolify API key")) {
                    Pasteboard.copy(store.coolifyAccount?.apiKey ?? "")
                }
                
                Button(String("Reset Coolify credentials"), role: .destructive) {
                    resetCoolifyCredentials()
                }
            }
            
            Section("Xcode Cloud") {
                Button("Connect credentials") {
                    sheetAuthConnect = true
                }
                .sheet($sheetAuthConnect) {
                    ConnectAuthView()
                }
                
                Button(String("Copy issuer ID")) {
                    Pasteboard.copy(store.connectAccount?.issuerID ?? "")
                }
                
                Button(String("Copy private key")) {
                    Pasteboard.copy(store.connectAccount?.privateKey ?? "")
                }
                
                Button(String("Copy private key ID")) {
                    Pasteboard.copy(store.connectAccount?.privateKeyID ?? "")
                }
                
                Button(String("Reset App Store Connect credentials"), role: .destructive) {
                    resetConnectCredentials()
                }
            }
        }
        .navigationTitle("Debug")
    }
    
    private func resetConnectCredentials() {
        guard let account = connectAccountModel else { return }
        
        account.issuerID = ""
        account.privateKey = ""
        account.privateKeyID = ""
        account.touch()
        
        try? modelContext.save()
        store.refreshSelection(for: .connect)
    }
    
    private func resetCoolifyCredentials() {
        guard let account = coolifyAccountModel else { return }
        
        account.coolifyDomain = "https://coolify.example.com"
        account.coolifyAPIKey = ""
        account.touch()
        
        try? modelContext.save()
        store.refreshSelection(for: .coolify)
    }
    
    private var connectAccountModel: ProviderAccount? {
        accountModel(for: store.connectAccount?.id)
    }
    
    private var coolifyAccountModel: ProviderAccount? {
        accountModel(for: store.coolifyAccount?.id)
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
    List {
        DebugSettings()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
    .modelContainer(PreviewModelContainer.inMemory)
}
