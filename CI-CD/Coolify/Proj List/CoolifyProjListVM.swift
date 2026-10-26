import Foundation
import OSLog
import ScrechKit

@Observable
final class CoolifyProjListVM {
    var projects: [CoolifyProject] = []
    var errorMessage: String?
    private var latestRequestID = UUID()
    private var projectsAccount: CoolifyAccountSnapshot?
    
    func fetchProjects(store: ValueStore) async {
        let requestID = UUID()
        latestRequestID = requestID
        errorMessage = nil

        if projectsAccount != store.coolifyAccount {
            projects = []
            projectsAccount = store.coolifyAccount
            if let account = projectsAccount, account.isAuthorized, !account.demoMode {
                projects = CoolifyProjectCache(accountID: account.id, domain: account.domain).load() ?? []
            }
        }

        if store.coolifyDemoMode {
            projects = [Preview.coolifyProj]
            return
        }

        guard let account = store.coolifyAccount, account.isAuthorized else {
            projects = []
            return
        }
        
        guard let url = CoolifyAPIEndpoint.fetchProjects(domain: account.domain) else {
            errorMessage = String(localized: "Enter a valid Coolify URL in account settings")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let apiKey = account.apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await CoolifyTransport.data(for: request, account: account)
            try Task.checkCancellation()
            guard latestRequestID == requestID, store.coolifyAccount == account else { return }

            projects = try CoolifyAPIResponse.decode([CoolifyProject].self, from: data, response: response)
            saveCache()
        } catch {
            guard !Task.isCancelled, latestRequestID == requestID, store.coolifyAccount == account else { return }
            errorMessage = error.localizedDescription
            Logger().error("Error fetching projects: \(error)")
        }
    }

    func updateProject(_ project: CoolifyProject, account: CoolifyAccountSnapshot?) {
        guard account == projectsAccount,
              let index = projects.firstIndex(where: { $0.uuid == project.uuid }) else { return }
        projects[index] = project
        saveCache()
    }

    private func saveCache() {
        guard let account = projectsAccount, account.isAuthorized, !account.demoMode else { return }
        do {
            try CoolifyProjectCache(accountID: account.id, domain: account.domain).save(projects)
        } catch {
            Logger().error("Failed to cache Coolify projects: \(error)")
        }
    }
}
