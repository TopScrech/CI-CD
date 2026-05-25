import ScrechKit

struct GitHubWorkflowRow: View {
    private let workflow: GitHubWorkflow
    private let run: (GitHubWorkflow) -> Void
    
    init(_ workflow: GitHubWorkflow, run: @escaping (GitHubWorkflow) -> Void) {
        self.workflow = workflow
        self.run = run
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(workflow.name)
                        .headline()
                    
                    Text(workflow.path)
                        .caption()
                        .secondary()
                }
                
                Spacer()
                
                Button("Run", systemImage: "play", action: runWorkflow)
                    .buttonStyle(.bordered)
            }
            
            Text(workflow.state)
                .caption()
                .secondary()
        }
        .contextMenu {
            Button("Run workflow", systemImage: "play", action: runWorkflow)
            
            if let url = workflow.htmlURL {
                Link(destination: url) {
                    Label("Open in GitHub", systemImage: "safari")
                }
            }
        }
    }
    
    private func runWorkflow() {
        run(workflow)
    }
}

#Preview {
    List {
        GitHubWorkflowRow(GitHubPreview.workflow) { _ in }
    }
    .darkSchemePreferred()
}
