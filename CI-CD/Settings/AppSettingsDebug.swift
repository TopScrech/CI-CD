import ScrechKit

struct AppSettingsDebug: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        DisclosureGroup("Debug") {
            Button {
                store.isAuthorized = false
            } label: {
                HStack {
                    Text("Log out")
                    
                    Spacer()
                    
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .secondary()
                }
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
