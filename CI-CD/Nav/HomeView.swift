import ScrechKit

struct HomeView: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
#if os(visionOS)
        VisionSidebarView()
            .toolbar {
                NavigationLink {
                    AppSettings()
                } label: {
                    Image(systemName: "gear")
                }
                .keyboardShortcut("s")
            }
#else
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
#endif
    }
}

#Preview {
    HomeView()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
        .modelContainer(PreviewModelContainer.inMemory)
}
