import ScrechKit

struct PanelSidebarSectionView: View {
    let section: PanelSidebarSection
    let selectedTab: HomeViewTab
    let onSelect: (HomeViewTab) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(section.title)
                .caption(.semibold)
                .secondary()
                .padding(.horizontal, 10)
                .padding(.vertical, 2)
            
            ForEach(section.tabs) { tab in
                PanelSidebarTabRow(tab: tab, isSelected: selectedTab == tab) {
                    onSelect(tab)
                }
            }
        }
    }
}
