import Foundation
import OSLog

@Observable
final class GitHubRepoDetailsVM {
    var workflows: [GitHubWorkflow] = []
    var runs: [GitHubWorkflowRun] = []
    var errorMessage: String?
    
    func fetch(repository: GitHubRepository, store: ValueStore) async {
        if store.githubDemoMode {
            workflows = [GitHubPreview.workflow]
            runs = [GitHubPreview.workflowRun]
            errorMessage = nil
            return
        }
        
        guard let account = store.githubAccount, account.isAuthorized else {
            workflows = []
            runs = []
            errorMessage = nil
            return
        }
        
        let client = GitHubAPIClient(account: account)
        
        do {
            async let fetchedWorkflows = client.workflows(owner: repository.ownerName, repository: repository.name)
            async let fetchedRuns = client.workflowRuns(owner: repository.ownerName, repository: repository.name)
            workflows = try await fetchedWorkflows
            runs = try await fetchedRuns
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            Logger().error("Error fetching GitHub Actions data: \(error)")
        }
    }
    
    func dispatch(_ workflow: GitHubWorkflow, repository: GitHubRepository, store: ValueStore) async {
        if store.githubDemoMode {
            runs.insert(GitHubPreview.workflowRun, at: 0)
            return
        }
        
        guard let account = store.githubAccount, account.isAuthorized else { return }
        
        do {
            try await GitHubAPIClient(account: account).dispatchWorkflow(
                owner: repository.ownerName,
                repository: repository.name,
                workflowID: workflow.id,
                ref: repository.defaultBranch
            )
            await fetch(repository: repository, store: store)
        } catch {
            errorMessage = error.localizedDescription
            Logger().error("Error dispatching GitHub workflow: \(error)")
        }
    }
    
    func rerun(_ run: GitHubWorkflowRun, repository: GitHubRepository, store: ValueStore) async {
        guard !store.githubDemoMode else { return }
        guard let account = store.githubAccount, account.isAuthorized else { return }
        
        do {
            try await GitHubAPIClient(account: account).rerun(
                owner: repository.ownerName,
                repository: repository.name,
                runID: run.id
            )
            await fetch(repository: repository, store: store)
        } catch {
            errorMessage = error.localizedDescription
            Logger().error("Error rerunning GitHub workflow: \(error)")
        }
    }
    
    func cancel(_ run: GitHubWorkflowRun, repository: GitHubRepository, store: ValueStore) async {
        guard !store.githubDemoMode else { return }
        guard let account = store.githubAccount, account.isAuthorized else { return }
        
        do {
            try await GitHubAPIClient(account: account).cancel(
                owner: repository.ownerName,
                repository: repository.name,
                runID: run.id
            )
            await fetch(repository: repository, store: store)
        } catch {
            errorMessage = error.localizedDescription
            Logger().error("Error cancelling GitHub workflow: \(error)")
        }
    }
}
