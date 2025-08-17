import ScrechKit
import AppStoreConnect_Swift_SDK

struct IssueCard: View {
    private let issue: CiIssue
    
    init(_ issue: CiIssue) {
        self.issue = issue
    }
    
    private var icon: String {
        switch issue.attributes?.issueType {
        case .warning, .analyzerWarning: "⚠️ "
        case .error, .testFailure: "⛔️ "
        case nil: ""
        }
    }
    
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 0) {
                    Text(icon)
                    
                    Text(issue.attributes?.issueType?.rawValue.lowercased().capitalized ?? "-")
                        .secondary()
                }
                
                Text(issue.attributes?.message ?? "-")
                    .monospaced()
            }
            .contextMenu {
                if let message = issue.attributes?.message {
                    Button("Copy", systemImage: "document.on.document") {
                        Pasteboard.copy(message)
                    }
                }
            }
        } footer: {
            if let source = issue.attributes?.fileSource, let line = source.lineNumber, let path = source.path {
                HStack(alignment: .top, spacing: 4) {
                    Text("Line")
                        .opacity(0.8)
                    
                    Text(line)
                    
                    Text("in")
                        .opacity(0.8)
                    
                    Text(path)
                }
                .multilineTextAlignment(.leading)
            }
        }
    }
}

#Preview {
    List {
        IssueCard(CiIssue.preview)
        IssueCard(CiIssue.preview)
        IssueCard(CiIssue.preview)
    }
    .darkSchemePreferred()
}
