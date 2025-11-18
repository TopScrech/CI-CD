import Foundation

@Observable
final class CoolifyProjDetailsVM {
    var apps: [CoolifyApp] = []
    
    func load(_ project: CoolifyProject) async {
        let store = ValueStore()
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // 1) Fetch environments for the project so we know which apps belong here.
        let envPath = store.coolifyDomain + "/api/v1/projects/\(project.uuid)/environments"
        guard let envURL = URL(string: envPath) else {
            return
        }
        
        var envRequest = URLRequest(url: envURL)
        envRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        envRequest.setValue("Bearer \(store.coolifyAPIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (envData, _) = try await URLSession.shared.data(for: envRequest)
            let environments = try decoder.decode([CoolifyProjectEnv].self, from: envData)
            let envLookup = Dictionary(uniqueKeysWithValues: environments.map { ($0.id, $0) })
            let envIds = Set(envLookup.keys)
            
            let appsPath = store.coolifyDomain + "/api/v1/applications"
            
            guard let appsURL = URL(string: appsPath) else {
                return
            }
            
            var appsRequest = URLRequest(url: appsURL)
            appsRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            appsRequest.setValue("Bearer \(store.coolifyAPIKey)", forHTTPHeaderField: "Authorization")
            
            let (appData, _) = try await URLSession.shared.data(for: appsRequest)
            
            var decodedApps = try decoder.decode([CoolifyApp].self, from: appData)
            
            // Attach environment names and filter down to the current project
            decodedApps = decodedApps.compactMap { app in
                guard envIds.contains(app.environmentId) else {
                    return nil
                }
                
                var enrichedApp = app
                enrichedApp.environmentName = envLookup[app.environmentId]?.name
                
                return enrichedApp
            }
            
            self.apps = decodedApps
        } catch {
            print("Error fetching project details:", error)
        }
    }
}
