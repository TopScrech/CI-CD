import ScrechKit

struct AppSettingsDebug: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        DisclosureGroup("Debug") {
            TextField("Coolify API-key", text: $store.coolifyAPIKey)
                .autocorrectionDisabled()
            
            TextField("Coolify domain", text: $store.coolifyDomain)
                .autocorrectionDisabled()
                .textContentType(.URL)
                .keyboardType(.URL)
            
            Button("Copy issuer ID") {
                Pasteboard.copy(store.issuer)
            }
            
            Button("Copy private key") {
                Pasteboard.copy(store.privateKey)
            }
            
            Button("Copy private key ID") {
                Pasteboard.copy(store.privateKeyId)
            }
            
            Toggle("Status bar", isOn: $store.showStatusBar)
            
            Button("Log out", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive) {
                store.isAuthorized = false
            }
            .foregroundStyle(.red)
        }
    }
}

#Preview {
    List {
        AppSettingsDebug()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
