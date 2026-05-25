import SwiftUI

struct AppSettings: View {
    var body: some View {
        List {
            AppearanceSettingsSection()
            DemoSettingsSection()
            FeedbackSettingsSection()
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Settings")
        .ornamentDismissButton()
        .foregroundStyle(.foreground)
        .toolbar {
            NavigationLink {
                DebugSettings()
            } label: {
                Label("Debug", systemImage: "hammer")
            }
        }
    }
}

#Preview {
    NavigationStack {
        AppSettings()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
