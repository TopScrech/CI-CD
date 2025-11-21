import ScrechKit

@Observable
final class CoolifyAppDetailsVM {
    var isLoading = true
    var deployments: [CoolifyDeployment] = []
    
    var newName = ""
    var newDescription = ""
    
    func fetchDeployments(_ appUUID: String) async {
        defer {
            withAnimation {
                isLoading = false
            }
        }
        
        let store = ValueStore()
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let url = CoolifyAPIEndpoint.fetchDeployments(appUUID) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(store.coolifyAPIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            print(prettyJSON(data) ?? "Invalid JSON")
            
            let response = try decoder.decode(DeploymentResponse.self, from: data)
            deployments = response.deployments
        } catch {
            print("Error fetching deployments:", error)
        }
    }
    
    func renameApp(_ app: CoolifyApp) async -> CoolifyApp? {
        var patchedApp = app
        patchedApp.name = newName
        patchedApp.description = newDescription
        
        let store = ValueStore()
        
        guard let url = CoolifyAPIEndpoint.app(app.uuid) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(store.coolifyAPIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(patchedApp)
            
            let (_, _) = try await URLSession.shared.data(for: request)
            
            return await fetchApp(app.uuid)
        } catch {
            print("Error renaming app:", error.localizedDescription)
            return nil
        }
    }
    
    func fetchApp(_ appUUID: String) async -> CoolifyApp? {
        let store = ValueStore()
        
        guard let url = CoolifyAPIEndpoint.app(appUUID) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(store.coolifyAPIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            print("Fetched app:", prettyJSON(data) ?? "Invalid JSON")
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            return try decoder.decode(CoolifyApp.self, from: data)
        } catch {
            print("Error fetching app:", error.localizedDescription)
            return nil
        }
    }
}
