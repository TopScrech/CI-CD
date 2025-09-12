import SwiftUI
import MailCover

struct AppSettingsFeedback: View {
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
        AppSettingsFeedback()
    }
    .darkSchemePreferred()
}
