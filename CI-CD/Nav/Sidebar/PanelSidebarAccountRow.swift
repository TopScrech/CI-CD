import ScrechKit

struct PanelSidebarAccountRow: View {
    let account: ProviderAccount
    let isSelected: Bool
    let action: () -> Void
    let edit: () -> Void
    let delete: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(account.effectiveName)
                    .subheadline(.semibold)
                    .lineLimit(1)
                
                Spacer(minLength: 0)
                
                Image(account.provider.logoAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .clipShape(.rect(cornerRadius: 5))
            }
            .foregroundStyle(.foreground)
            .padding(.vertical, 7)
            .padding(.horizontal, 10)
            .background(isSelected ? .gray.opacity(0.2) : .clear, in: .rect(cornerRadius: 12))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Edit", systemImage: "pencil", action: edit)
            
            Divider()
            
            Button("Delete", systemImage: "trash", role: .destructive, action: delete)
        }
    }
}
