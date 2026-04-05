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
            DemoSettingsSection()
            AppSettingsFeedback()
#if DEBUG
            NavigationLink {
                DebugSettings()
            } label: {
                Label("Debug", systemImage: "hammer")
            }
#endif
        }
        .scrollIndicators(.hidden)
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
