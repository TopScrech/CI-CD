import SwiftUI
import Kingfisher

struct BuildCard: View {
    private let build: CIBuildRun
    
    init(_ build: CIBuildRun) {
        self.build = build
    }
    
    private var statusColor: Color {
        switch build.attributes.completionStatus {
        case "SUCCEEDED": .green
        case "FAILED": .red
        case "CANCELED": .gray
        default: .gray
        }
    }
    
    private let imgSize = 32.0
    
    var body: some View {
        let commit = build.attributes.sourceCommit
        let author = commit.author
        
        HStack {
            Capsule()
                .frame(width: 5, height: 120)
                .foregroundStyle(statusColor.gradient)
            
            VStack(alignment: .leading) {
                Text("Build \(build.attributes.number)")
                    .title3(.semibold, design: .rounded)
                
                Text(commit.message)
                
                Text(commit.commitSha)
                    .secondary()
                
                HStack {
                    KFImage(URL(string: author.avatarUrl))
                        .resizable()
                        .frame(width: imgSize, height: imgSize)
                        .clipShape(.circle)
                    
                    Text(author.displayName)
                }
            }
            
            Spacer()
            
            VStack {
                Text(timeSinceISO(build.attributes.createdDate))
                
                Text(timeDiffISO(
                    dateString1: build.attributes.startedDate,
                    dateString2: build.attributes.finishedDate
                ))
            }
            .footnote()
            .secondary()
        }
        .padding(.leading, -8)
    }
    
    private func timeDiffISO(dateString1: String, dateString2: String) -> LocalizedStringKey {
        let formatter = ISO8601DateFormatter()
        
        guard
            let date1 = formatter.date(from: dateString1),
            let date2 = formatter.date(from: dateString1)
        else {
            return "-"
        }
        
        let secDiff = date1.timeIntervalSince(date2)
        let minDiff = Int(secDiff / 60)
        
//        return "Build time: **\(minDiff)m**"
        return "Ran for **\(minDiff)m**"
    }
    
#warning("Move to ScrechKit, remove from BH")
    private func timeSinceISO(_ date: String) -> LocalizedStringKey {
        let formatter = ISO8601DateFormatter()
        
        guard let date = formatter.date(from: date) else {
            return "-"
        }
        
        let sinceNowSeconds = Int(date.timeIntervalSinceNow * -1)
        
        guard sinceNowSeconds > 1 else {
            return "Now"
        }
        
        guard sinceNowSeconds > 60 else {
            return "\(sinceNowSeconds) seconds ago"
        }
        
        let sinceNowMinutes = sinceNowSeconds / 60
        guard sinceNowMinutes > 60 else {
            return "\(sinceNowMinutes) minutes ago"
        }
        
        let sinceNowHours = sinceNowMinutes / 60
        guard sinceNowHours > 24 else {
            return "\(sinceNowHours) hours ago"
        }
        
        let sinceNowDays = sinceNowHours / 24
        return "\(sinceNowDays) days ago"
    }
}

#Preview {
    NavigationView {
        List {
            NavigationLink {
                
            } label: {
                BuildCard(CIBuildRun.preview)
            }
        }
    }
    .darkSchemePreferred()
}
