import ScrechKit

struct HomeView: View {
    var body: some View {
        TabView {
            AppList()
                .tag(0)
                .tabItem {
                    Label("Connect", systemImage: "app.dashed")
                }
            
            ProjList()
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
