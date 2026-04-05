import SwiftUI

struct AppSettings: View {
    var body: some View {
        List {
            AppearanceSettingsSection()
            DemoSettingsSection()
            FeedbackSettingsSection()
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
