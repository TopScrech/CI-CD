import ScrechKit

struct DebugSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Section("Debug") {
            Button {
                store.isAuthorized = false
            } label: {
                HStack {
                    Text("Deauthorize")
                    
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
    DebugSettings()
}
