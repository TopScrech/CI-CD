import Foundation
import OSLog

@Observable
final class GitHubRunDetailsVM {
    var jobs: [GitHubWorkflowJob] = []
    var artifacts: [GitHubArtifact] = []
    var errorMessage: String?
    
    func fetch(run: GitHubWorkflowRun, repository: GitHubRepository, store: ValueStore) async {
        if store.githubDemoMode {
            jobs = [GitHubPreview.job]
            artifacts = [GitHubPreview.artifact]
            errorMessage = nil
            return
        }
        
        guard let account = store.githubAccount, account.isAuthorized else {
            jobs = []
            artifacts = []
            errorMessage = nil
            return
        }
        
        let client = GitHubAPIClient(account: account)
        
        do {
            async let fetchedJobs = client.workflowJobs(owner: repository.ownerName, repository: repository.name, runID: run.id)
            async let fetchedArtifacts = client.artifacts(owner: repository.ownerName, repository: repository.name, runID: run.id)
            
            let jobs = try await fetchedJobs
            self.jobs = jobs
            artifacts = try await fetchedArtifacts
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            Logger().error("Error fetching GitHub run details: \(error)")
        }
    }
}
