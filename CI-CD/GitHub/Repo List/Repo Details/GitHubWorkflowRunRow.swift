import ScrechKit

struct GitHubWorkflowRunRow: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    
    private let run: GitHubWorkflowRun
    private let rerun: () -> Void
    private let cancel: () -> Void
    
    init(_ run: GitHubWorkflowRun, rerun: @escaping () -> Void, cancel: @escaping () -> Void) {
        self.run = run
        self.rerun = rerun
        self.cancel = cancel
    }
    
    var body: some View {
        HStack {
            Capsule()
                .frame(width: 5, height: 50)
                .foregroundStyle(statusColor.gradient)
                .padding(.vertical, 5)
            
            VStack(alignment: .leading) {
                if differentiateWithoutColor {
                    Text(statusText)
                }
                
                Text(run.displayTitle)
                    .headline()
                
                HStack(spacing: 0) {
                    if let branch = run.headBranch {
                        Text(branch)
                        
                        Text(" • ")
                    }
                    
                    Text(run.event)
                }
                .caption()
                .secondary()
            }
        }
        .monospacedDigit()
        .padding(.leading, -8)
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
    
    private var statusText: String {
        if let conclusion = run.conclusion {
            return conclusion
        }
        
        return run.status ?? String(localized: "Unknown")
    }
    
    private var statusColor: Color {
        switch run.conclusion ?? run.status {
        case "success": .green
        case "failure", "timed_out", "action_required": .red
        case "cancelled", "skipped", "neutral": .gray
        default: .gray
        }
    }
}

#Preview {
    List {
        GitHubWorkflowRunRow(GitHubPreview.workflowRun) {} cancel: {}
    }
    .darkSchemePreferred()
}
