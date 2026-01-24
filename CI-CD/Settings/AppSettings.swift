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
                Toggle(isOn: $store.connectDemoMode) {
                    Label("Connect demo", systemImage: "hammer")
                }
                
                Toggle(isOn: $store.coolifyDemoMode) {
                    Label("Coolify demo", systemImage: "cloud")
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
