import ScrechKit

struct HomeView: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        PanelSidebarView()
        .navigationTitle(store.lastTab.title)
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
        .modelContainer(PreviewModelContainer.inMemory)
}
