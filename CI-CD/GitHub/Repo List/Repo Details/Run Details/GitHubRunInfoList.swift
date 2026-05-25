import ScrechKit

struct GitHubRunInfoList: View {
    let run: GitHubWorkflowRun
    let jobs: [GitHubWorkflowJob]
    let errorMessage: String?
    
    var body: some View {
        List {
            if let errorMessage {
                ContentUnavailableView("GitHub error", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
            }
            
            Section("Run") {
                LabeledContent("Title", value: run.displayTitle)
                LabeledContent("Status", value: statusText)
                LabeledContent("Event", value: run.event)
                
                if let branch = run.headBranch {
                    LabeledContent("Branch", value: branch)
                }
                
                LabeledContent("Commit", value: String(run.headSha.prefix(7)))
                
                if let actor = run.actor {
                    LabeledContent("Actor", value: actor.login)
                }
                
                LabeledContent("Created") {
                    Text(run.createdAt, format: .dateTime)
                }
                
                if let runStartedAt = run.runStartedAt {
                    LabeledContent("Started") {
                        Text(runStartedAt, format: .dateTime)
                    }
                }
                
                LabeledContent("Updated") {
                    Text(run.updatedAt, format: .dateTime)
                }
            }
            
            Section("Jobs") {
                if jobs.isEmpty {
                    ContentUnavailableView("No jobs found", systemImage: "gearshape.2")
                } else {
                    ForEach(jobs) {
                        GitHubJobRow($0)
                    }
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
}

#Preview {
    GitHubRunInfoList(run: GitHubPreview.workflowRun, jobs: [GitHubPreview.job], errorMessage: nil)
        .darkSchemePreferred()
}
