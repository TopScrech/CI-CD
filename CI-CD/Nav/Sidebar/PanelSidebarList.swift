import ScrechKit

struct PanelSidebarList: View {
    var onSelect: (HomeViewTab) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PanelSidebarAccountsSection(onSelect: onSelect)
                
                PanelSidebarAddAccountButton()
                    .padding(.top, 14)
            }
            .padding(12)
        }
        .scrollIndicators(.never)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    @Previewable @State var tab: HomeViewTab = .connect
    
    PanelSidebarList {
        tab = $0
    }
    .environmentObject(ValueStore())
    .modelContainer(PreviewModelContainer.inMemory)
}
