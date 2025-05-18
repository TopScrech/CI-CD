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
                .frame(width: 5)
                .frame(maxHeight: .infinity)
                .foregroundStyle(statusColor.gradient)
                .padding(.vertical, 5)
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Build \(build.attributes.number)")
                        .title3(.semibold, design: .rounded)
                    
                    Text(commit.id)
                        .secondary()
                        .padding(.vertical, 2)
                        .padding(.horizontal, 8)
                        .background(.ultraThinMaterial, in: .capsule)
                }
                
                Text(commit.message)
                
                //                Text(commit.id)
                //                    .secondary()
                
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
                
                if let minDiff = timeDiffISO(dateString1: build.attributes.createdDate, dateString2: build.attributes.startedDate) {
                    HStack(spacing: 2) {
                        Image(systemName: "clock")
                        Text("\(minDiff)m")
                    }
                    .tertiary()
                    .semibold()
                }
            }
            .footnote()
            .secondary()
        }
        .monospacedDigit()
        .padding(.leading, -8)
    }
    
    private func timeDiffISO(dateString1: String?, dateString2: String?) -> Int? {
        let formatter = ISO8601DateFormatter()
        
        guard
            let dateString1,
            let dateString2,
            let date1 = formatter.date(from: dateString1),
            let date2 = formatter.date(from: dateString2)
        else {
            return nil
        }
        
        let secDiff = date2.timeIntervalSince(date1)
        let minDiff = Int(secDiff / 60)
        
        //        return "Build time: **\(minDiff)m**"
        return minDiff
    }
    
#warning("Move to ScrechKit, remove from BH")
    private func timeSinceISO(_ date: String) -> LocalizedStringKey {
        let formatter = ISO8601DateFormatter()
        
        guard let date = formatter.date(from: date) else {
            return ""
        }
        
        let sinceNowSeconds = Int(date.timeIntervalSinceNow * -1)
        
        guard sinceNowSeconds > 1 else {
            return "Now"
        }
        
        guard sinceNowSeconds > 60 else {
            return "\(sinceNowSeconds)s ago"
        }
        
        let sinceNowMinutes = sinceNowSeconds / 60
        guard sinceNowMinutes > 60 else {
            return "\(sinceNowMinutes)m ago"
        }
        
        let sinceNowHours = sinceNowMinutes / 60
        guard sinceNowHours > 24 else {
            return "\(sinceNowHours)h ago"
        }
        
        let sinceNowDays = sinceNowHours / 24
        return "\(sinceNowDays)d ago"
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
