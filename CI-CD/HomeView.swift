import ScrechKit

struct HomeView: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        TabView(selection: $store.lastTab) {
            AppList()
                .tag(0)
                .tabItem {
                    Label("Connect", systemImage: "app.dashed")
                }
            
            CoolifyProjList()
                .tag(1)
                .tabItem {
                    Label("Coolify", systemImage: "globe")
                }
        }
        .toolbar {
            NavigationLink {
                AppSettings()
            } label: {
                Image(systemName: "gear")
            }
            .keyboardShortcut("s")
        }
    }
}

#Preview {
    HomeView()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
