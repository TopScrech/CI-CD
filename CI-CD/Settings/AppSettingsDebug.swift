import ScrechKit

struct AppSettingsDebug: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        DisclosureGroup("Debug") {
            Button("Copy issuer ID") {
                Pasteboard.copy(store.issuer)
            }
            
            Button("Copy private key") {
                Pasteboard.copy(store.privateKey)
            }
            
            Button("Copy private key ID") {
                Pasteboard.copy(store.privateKeyId)
            }
            
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
