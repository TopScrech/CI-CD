import ScrechKit

struct GitHubJobStepRow: View {
    private let step: GitHubWorkflowStep
    
    init(_ step: GitHubWorkflowStep) {
        self.step = step
    }
    
    var body: some View {
        HStack {
            Text(step.name)
                .caption()
            
            Spacer()
            
            Text(statusText)
                .caption()
                .secondary()
        }
    }
    
    private var statusText: String {
        if let conclusion = step.conclusion {
            return conclusion
        }
        
        return step.status
    }
}
