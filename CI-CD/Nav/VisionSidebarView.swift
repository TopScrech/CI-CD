import ScrechKit

struct VisionSidebarView: View {
    @EnvironmentObject private var store: ValueStore
    
    @State private var selectedTab = HomeViewTab.connect
    
    var body: some View {
        NavigationSplitView {
            List {
                Section("Services") {
                    ForEach(HomeViewTab.allCases) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label {
                                Text(tab.title)
                            } icon: {
                                Image(systemName: tab.systemImage)
                            }
                        }
                    }
                }
            }
            .navigationTitle("CI-CD")
        } detail: {
            HomeViewTabContent(selectedTab: selectedTab)
                .id(selectedTab)
                .navigationTitle(selectedTab.title)
        }
        .onAppear {
            selectedTab = store.lastTab
        }
        .onChange(of: selectedTab) { _, newValue in
            store.lastTab = newValue
        }
        .onChange(of: store.lastTab) { _, newValue in
            selectedTab = newValue
        }
    }
}

#Preview {
    VisionSidebarView()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
        .modelContainer(PreviewModelContainer.inMemory)
}
