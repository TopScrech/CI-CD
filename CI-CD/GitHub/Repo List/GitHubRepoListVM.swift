import Foundation
import OSLog

@Observable
final class GitHubRepoListVM {
    var repositories: [GitHubRepository] = []
    var errorMessage: String?
    
    func fetchRepositories(store: ValueStore) async {
        if store.githubDemoMode {
            repositories = [GitHubPreview.repository]
            errorMessage = nil
            return
        }
        
        guard let account = store.githubAccount, account.isAuthorized else {
            repositories = []
            errorMessage = nil
            return
        }
        
        do {
            repositories = try await GitHubAPIClient(account: account).repositories()
            errorMessage = nil
        } catch {
            repositories = []
            errorMessage = error.localizedDescription
            Logger().error("Error fetching GitHub repositories: \(error)")
        }
    }
}
