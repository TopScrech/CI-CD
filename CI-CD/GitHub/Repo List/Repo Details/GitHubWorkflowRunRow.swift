import ScrechKit

struct GitHubWorkflowRunRow: View {
    private let run: GitHubWorkflowRun
    private let rerun: () -> Void
    private let cancel: () -> Void
    
    init(_ run: GitHubWorkflowRun, rerun: @escaping () -> Void, cancel: @escaping () -> Void) {
        self.run = run
        self.rerun = rerun
        self.cancel = cancel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(run.displayTitle)
                        .headline()
                    
                    Text(subtitle)
                        .caption()
                        .secondary()
                }
                
                Spacer()
                
                Image(systemName: statusImage)
                    .foregroundStyle(statusStyle)
            }
            
            HStack {
                if let branch = run.headBranch {
                    Label(branch, systemImage: "arrow.triangle.branch")
                }
                
                Text(run.event)
            }
            .caption()
            .secondary()
        }
        .contextMenu {
            Button("Rerun", systemImage: "arrow.clockwise", action: rerun)
            
            if run.status == "in_progress" || run.status == "queued" {
                Button("Cancel", systemImage: "xmark", role: .destructive, action: cancel)
            }
            
            if let url = run.htmlURL {
                Link(destination: url) {
                    Label("Open in GitHub", systemImage: "safari")
                }
            }
        }
    }
    
    private var subtitle: String {
        if let conclusion = run.conclusion {
            return conclusion
        }
        
        return run.status ?? String(localized: "Unknown")
    }
    
    private var statusImage: String {
        switch run.conclusion ?? run.status {
        case "success": "checkmark.circle.fill"
        case "failure", "cancelled", "timed_out": "xmark.circle.fill"
        case "in_progress", "queued", "waiting", "requested": "clock.fill"
        default: "questionmark.circle"
        }
    }
    
    private var statusStyle: HierarchicalShapeStyle {
        switch run.conclusion ?? run.status {
        case "success": .primary
        case "failure", "cancelled", "timed_out": .secondary
        case "in_progress", "queued", "waiting", "requested": .primary
        default: .secondary
        }
    }
}

#Preview {
    List {
        GitHubWorkflowRunRow(GitHubPreview.workflowRun) {} cancel: {}
    }
    .darkSchemePreferred()
}
