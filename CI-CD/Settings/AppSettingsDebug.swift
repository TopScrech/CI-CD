import ScrechKit

struct AppSettingsDebug: View {
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetAuthConnect = false
    @State private var sheetAuthCoolify = false
    
    var body: some View {
        DisclosureGroup("Debug") {
            Button("Coolify credentials") {
                sheetAuthCoolify = true
            }
            .sheet($sheetAuthCoolify) {
                CoolifyAuthView()
            }
            
            Button("Connect credentials") {
                sheetAuthConnect = true
            }
            .sheet($sheetAuthConnect) {
                ConnectAuthView()
            }
            
            Button("Copy issuer ID") {
                Pasteboard.copy(store.issuer)
            }
            
            Button("Copy private key") {
                Pasteboard.copy(store.privateKey)
            }
            
            Button("Copy private key ID") {
                Pasteboard.copy(store.privateKeyId)
            }
#if os(iOS)
            Toggle("Status bar", isOn: $store.showStatusBar)
#endif
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
