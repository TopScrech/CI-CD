import ScrechKit

struct GitHubJobRow: View {
    private let job: GitHubWorkflowJob
    
    init(_ job: GitHubWorkflowJob) {
        self.job = job
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(job.name)
                    .headline()
                
                Spacer()
                
                Text(statusText)
                    .caption()
                    .secondary()
            }
            
            if let steps = job.steps, !steps.isEmpty {
                ForEach(steps) {
                    GitHubJobStepRow($0)
                }
            }
        }
        .contextMenu {
            if let url = job.htmlURL {
                Link(destination: url) {
                    Label("Open in GitHub", systemImage: "safari")
                }
            }
        }
    }
    
    private var statusText: String {
        if let conclusion = job.conclusion {
            return conclusion
        }
        
        return job.status
    }
}

#Preview {
    List {
        GitHubJobRow(GitHubPreview.job)
    }
    .darkSchemePreferred()
}
