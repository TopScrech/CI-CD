import ScrechKit

struct PanelSidebarTabRow: View {
    let tab: HomeViewTab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: tab.systemImage)
                    .headline()
                    .frame(width: 24)
                
                Text(tab.localizedTitle)
                    .semibold()
                
                Spacer(minLength: 0)
            }
            .foregroundStyle(.foreground)
            .padding(.vertical, 7)
            .padding(.horizontal, 10)
            .background(isSelected ? .gray.opacity(0.2) : .clear, in: .rect(cornerRadius: 12))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PanelSidebarTabRow(tab: .connect, isSelected: true) {
    }
    .padding()
}
