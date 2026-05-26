import ScrechKit

struct PanelSidebarList: View {
    let selectedTab: HomeViewTab
    var onSelect: (HomeViewTab) -> Void
    var onCustomize: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PanelSidebarAccountsSection(onSelect: onSelect)
                
                PanelSidebarAddAccountButton()
                    .padding(.top, 14)
                
                PanelSidebarCustomizationButton(action: onCustomize)
            }
            .padding(12)
        }
        .scrollIndicators(.never)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    @Previewable @State var tab: HomeViewTab = .connect
    
    PanelSidebarList(selectedTab: tab) {
        tab = $0
    } onCustomize: {
        
    }
    .environment(PanelSidebarCustomizationVM())
    .environmentObject(ValueStore())
    .modelContainer(PreviewModelContainer.inMemory)
}
