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
        .transparentList()
        .ornamentDismissButton()
        .foregroundStyle(.foreground)
    }
}

#Preview {
    AppSettings()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
