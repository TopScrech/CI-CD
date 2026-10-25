import ScrechKit

struct HomeView: View {
    @EnvironmentObject private var store: ValueStore

    @State private var sidebarProgress = 0.0

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
        PanelSidebarView(sidebarProgress: $sidebarProgress)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(store.lastTab.title)
                        .opacity(1 - sidebarProgress)
                        .transition(.opacity)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AppSettings()
                    } label: {
                        Image(systemName: "gear")
                    }
                    .keyboardShortcut("s")
                }
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
