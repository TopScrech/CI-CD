import SwiftUI

struct AppSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
#if os(iOS)
            AppearanceSettings()
#endif
            Section {
                Toggle("Demo Mode", isOn: $store.demoMode)
            }
            
            SettingsFeedback()
#if DEBUG
            DebugSettings()
#endif
        }
        .navigationTitle("Settings")
        .ornamentDismissButton()
        .foregroundStyle(.foreground)
    }
}

#Preview {
    NavigationStack {
        AppSettings()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
