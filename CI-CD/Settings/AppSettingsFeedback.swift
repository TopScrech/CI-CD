import SwiftUI
import MailCover

struct AppSettingsFeedback: View {
    @State private var mailCover = false
    
    var body: some View {
        Section {
            Button("Feedback", systemImage: "envelope") {
                mailCover = true
            }
            .mailCover($mailCover, subject: "CI/CD Feedback", recipients: ["topscrech@icloud.com"])
        }
    }
}

#Preview {
    List {
        AppSettingsFeedback()
    }
    .darkSchemePreferred()
}
