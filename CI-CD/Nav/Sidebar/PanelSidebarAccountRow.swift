import ScrechKit

struct PanelSidebarAccountRow: View {
    let account: ProviderAccount
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(account.effectiveName)
                        .subheadline(.semibold)
                        .lineLimit(1)
                    
                    Text(account.provider.title)
                        .caption()
                        .secondary()
                }
                
                Spacer(minLength: 0)
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .caption(.semibold)
                        .foregroundStyle(.tint)
                }
                
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
    }
}
