import SwiftUI
import MailCover

struct FeedbackSettingsSection: View {
    @State private var mailCover = false
    
    var body: some View {
        Section {
            Button("Feedback", systemImage: "envelope") {
                mailCover = true
            }
            .mailCover($mailCover, subject: String(localized: "CI/CD Feedback"), recipients: ["topscrech@icloud.com"])
        }
    }
}

#Preview {
    List {
        FeedbackSettingsSection()
    }
    .darkSchemePreferred()
}
