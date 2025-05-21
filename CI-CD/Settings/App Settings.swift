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
                Button {
                    store.isAuthorized = false
                } label: {
                    HStack {
                        Text("Deauthorize")
                        
                        Spacer()
                        
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .secondary()
                    }
                }
            }
#endif
            Section {
                Button {
                    mailCover = true
                } label: {
                    HStack {
                        Text("Feedback")
                        
                        Spacer()
                        
                        Image(systemName: "envelope")
                            .secondary()
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .transparentList()
        .mailCover($mailCover, subject: "CI/CD Feedback", recipients: ["topscrech@icloud.com"])
        .foregroundStyle(.foreground)
    }
}

#Preview {
    AppSettings()
        .environmentObject(ValueStore())
}
