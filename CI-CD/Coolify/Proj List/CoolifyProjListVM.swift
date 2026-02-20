import Foundation
import OSLog
import ScrechKit

@Observable
final class CoolifyProjListVM {
    var projects: [CoolifyProject] = []
    
    func fetchProjects(store: ValueStore) async {
        if store.coolifyDemoMode {
            projects = [Preview.coolifyProj]
            return
        }

        guard let account = store.coolifyAccount, account.isAuthorized else {
            projects = []
            return
        }
        
        guard let url = CoolifyAPIEndpoint.fetchProjects(domain: account.domain) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(account.apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            self.projects = try decoder.decode([CoolifyProject].self, from: data)
        } catch {
            Logger().error("Error fetching projects: \(error)")
        }
    }
}
