import SwiftUI

#if canImport(Appearance)
import Appearance
#endif

struct AppSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
#if canImport(Appearance)
            Section {
                AppearancePicker($store.appearance)
            }
#endif
            Section {
                Toggle(isOn: $store.demoMode) {
                    Label("Demo mode", systemImage: "hammer")
                }
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
