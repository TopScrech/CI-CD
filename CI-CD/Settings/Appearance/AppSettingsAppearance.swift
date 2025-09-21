import SwiftUI

struct AppSettingsAppearance: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Section {
            Picker(selection: $store.appearance) {
                ForEach(ColorTheme.allCases) { theme in
                    Text(theme.loc)
                        .tag(theme)
                }
            } label: {
                Label("Appearance", systemImage: "paintbrush")
            }
        }
    }
}

#Preview {
    List {
        AppSettingsAppearance()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
