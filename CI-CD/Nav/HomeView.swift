import ScrechKit

struct HomeView: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        TabView(selection: $store.lastTab) {
            Tab("Connect", systemImage: "app.dashed", value: .connect) {
                AppList()
            }
            
            Tab("Coolify", systemImage: "globe", value: .coolify) {
                CoolifyProjList()
            }
        }
        .navigationTitle(store.lastTab.rawValue.capitalized)
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
