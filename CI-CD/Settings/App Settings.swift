import SwiftUI
import MailCover

struct AppSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    @State private var mailCover = false
    
    var body: some View {
        List {
            Section {
                Toggle("Demo Mode", isOn: $store.demoMode)
            }
#if DEBUG
            Section {
                Button("Deauthorize") {
                    store.isAuthorized = false
                }
            }
#endif
            
            Section {
                Button {
                    mailCover = true
                } label: {
                    Label("Feedback", systemImage: "envelope")
                }
            }
        }
        .navigationTitle("Settings")
        .mailCover($mailCover, subject: "CI/CD Feedback", recipients: ["topscrech@icloud.com"])
        .foregroundStyle(.foreground)
    }
}

#Preview {
    AppSettings()
        .environmentObject(ValueStore())
}
