import ScrechKit

struct HomeView: View {
    @EnvironmentObject private var store: ValueStore
    @State private var showConnectAuth = false
    @State private var showCoolifyAuth = false
    
    var body: some View {
        TabView(selection: $store.lastTab) {
            Tab("Connect", systemImage: "app.dashed", value: .connect) {
                ConnectAppList()
            }
            
            Tab("Coolify", systemImage: "globe", value: .coolify) {
                CoolifyProjList()
            }
        }
        .navigationTitle(store.lastTab.rawValue.capitalized)
        .toolbar {
            AccountPickerMenu(
                showConnectAuth: { showConnectAuth = true },
                showCoolifyAuth: { showCoolifyAuth = true }
            )
            
            NavigationLink {
                AppSettings()
            } label: {
                Image(systemName: "gear")
            }
            .keyboardShortcut("s")
        }
        .sheet($showConnectAuth) {
            ConnectAuthView()
        }
        .sheet($showCoolifyAuth) {
            CoolifyAuthView()
        }
    }
}

#Preview {
    HomeView()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
        .modelContainer(PreviewModelContainer.inMemory)
}
