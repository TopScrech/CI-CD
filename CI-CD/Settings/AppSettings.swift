import SwiftUI

struct AppSettings: View {
    var body: some View {
        List {
            AppearanceSettingsSection()
            FeedbackSettingsSection()
            
            Section {
                Link(destination: URL(string: "https://github.com/TopScrech/CI-CD")!) {
                    HStack(spacing: 12) {
                        Image(.gitHub)
                            .resizable()
                            .frame(24)
                            .clipShape(.circle)
                        
                        Text("GitHub")
                    }
                }
                .tint(.primary)
            } footer: {
                Text("Bug reports, feature requests & contributions are always welcome!")
                    .secondary()
            }
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
