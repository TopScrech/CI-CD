import OSLog
import ScrechKit

@Observable
final class CoolifyAppDetailsVM {
    var isLoading = true
    var deployments: [CoolifyDeployment] = []
    
    var newName = ""
    var newDescription = ""
    
    func resetLoading() {
        isLoading = true
        deployments = []
    }
    
    func fetchDeployments(_ appUUID: String, store: ValueStore) async {
        defer {
            withAnimation {
                isLoading = false
            }
        }
        
        if store.coolifyDemoMode {
            deployments = Preview.coolifyDeployments
            return
        }

        guard let account = store.coolifyAccount, account.isAuthorized else {
            deployments = []
            return
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let url = CoolifyAPIEndpoint.fetchDeployments(appUUID, domain: account.domain) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(account.apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            Logger().info("Deployments: \(prettyJSON(data) ?? "Invalid JSON")")
            
            let response = try decoder.decode(DeploymentResponse.self, from: data)
            deployments = response.deployments
        } catch {
            Logger().error("Error fetching deployments: \(error)")
        }
    }
    
    func renameApp(_ app: CoolifyApp, store: ValueStore) async -> CoolifyApp? {
        var patchedApp = app
        patchedApp.name = newName
        patchedApp.description = newDescription
        
        if store.coolifyDemoMode {
            return patchedApp
        }

        guard let account = store.coolifyAccount, account.isAuthorized else {
            return nil
        }
        
        guard let url = CoolifyAPIEndpoint.app(app.uuid, domain: account.domain) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(account.apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(patchedApp)
            
            let (_, _) = try await URLSession.shared.data(for: request)
            
            return await fetchApp(app.uuid, store: store)
        } catch {
            Logger().error("Error renaming app: \(error)")
            return nil
        }
    }
    
    func fetchApp(_ appUUID: String, store: ValueStore) async -> CoolifyApp? {
        if store.coolifyDemoMode {
            return Preview.coolifyApps.first
        }

        guard let account = store.coolifyAccount, account.isAuthorized else {
            return nil
        }
        
        guard let url = CoolifyAPIEndpoint.app(appUUID, domain: account.domain) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(account.apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            Logger().info("Fetched app: \(prettyJSON(data) ?? "Invalid JSON")")
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            return try decoder.decode(CoolifyApp.self, from: data)
        } catch {
            Logger().error("Error fetching app: \(error)")
            return nil
        }
    }
}
