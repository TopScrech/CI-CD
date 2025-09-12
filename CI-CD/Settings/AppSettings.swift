import SwiftUI

struct AppSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
#if os(iOS)
            AppSettingsAppearance()
#endif
            Section {
                Toggle("Demo Mode", isOn: $store.demoMode)
            }
            
            AppSettingsFeedback()
#if DEBUG
            AppSettingsDebug()
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
