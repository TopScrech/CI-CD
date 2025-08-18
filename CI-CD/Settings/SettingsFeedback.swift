import SwiftUI
import MailCover

struct SettingsFeedback: View {
    @State private var mailCover = false
    
    var body: some View {
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
            .mailCover($mailCover, subject: "CI/CD Feedback", recipients: ["topscrech@icloud.com"])
        }
    }
}

#Preview {
    List {
        SettingsFeedback()
    }
    .darkSchemePreferred()
}
