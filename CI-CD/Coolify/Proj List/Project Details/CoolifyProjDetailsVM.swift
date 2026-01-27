import OSLog
import ScrechKit

@Observable
final class CoolifyProjDetailsVM {
    var apps: [CoolifyApp] = []
    var databases: [CoolifyDatabase] = []
    
    var projName = ""
    var projDescription = ""
    var alertRename = false
    
    func rename(_ projUUID: String) async -> CoolifyProject? {
        let store = ValueStore()
        
        if store.coolifyDemoMode {
            return CoolifyProject(
                id: Preview.coolifyProj.id,
                uuid: projUUID,
                name: projName,
                description: projDescription,
                environments: []
            )
        }
        
        guard let renameProjURL = CoolifyAPIEndpoint.proj(projUUID) else {
            return nil
        }
        
        let params = [
            "name": projName,
            "description": projDescription
        ]
        
        guard let body = try? JSONEncoder().encode(params) else {
            return nil
        }
        
        var renameRequest = URLRequest(url: renameProjURL)
        renameRequest.httpMethod = "PATCH"
        renameRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        renameRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        renameRequest.setValue("Bearer \(store.coolifyAPIKey)", forHTTPHeaderField: "Authorization")
        renameRequest.httpBody = body
        
        do {
            _ = try await URLSession.shared.data(for: renameRequest)
            return await fetchProject(projUUID)
        } catch {
            Logger().error("Error renaming proj: \(error)")
            return nil
        }
    }
    
    func load(_ projUUID: String) async {
        let store = ValueStore()
        
        if store.coolifyDemoMode {
            apps = Preview.coolifyApps
            databases = Preview.coolifyDatabases
            return
        }
        
        guard let environments = await fetchEnvironments(projUUID) else {
            return
        }
        
        let envIds = Set(environments.keys)
        
        async let apps = fetchApps(envIds: envIds, environments: environments)
        async let databases = fetchDatabases(envIds: envIds, environments: environments)
        
        self.apps = await apps ?? []
        self.databases = await databases ?? []
    }
    
    private func fetchEnvironments(_ projUUID: String) async -> [Int: CoolifyProjectEnv]? {
        let store = ValueStore()
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let url = CoolifyAPIEndpoint.fetchProjEnvironments(projUUID) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(store.coolifyAPIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let envs = try decoder.decode([CoolifyProjectEnv].self, from: data)
            
            return Dictionary(uniqueKeysWithValues: envs.map { ($0.id, $0) })
        } catch {
            Logger().error("Error fetching environments: \(error)")
            return nil
        }
    }
    
    func fetchProject(_ projUUID: String) async -> CoolifyProject? {
        let store = ValueStore()
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let url = CoolifyAPIEndpoint.proj(projUUID) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(store.coolifyAPIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return try decoder.decode(CoolifyProject.self, from: data)
        } catch {
            Logger().error("Error fetching project: \(error)")
            return nil
        }
    }
    
    private func fetchApps(envIds: Set<Int>, environments: [Int: CoolifyProjectEnv]) async -> [CoolifyApp]? {
        let store = ValueStore()
        
        guard let url = CoolifyAPIEndpoint.fetchApps() else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(store.coolifyAPIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            Logger().info("Fetched apps: \(prettyJSON(data) ?? "Invalid JSON")")
            
            let apps = try decoder.decode([CoolifyApp].self, from: data)
            
            guard
                let object = try? JSONSerialization.jsonObject(with: data),
                let formatted = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
                let string = String(data: formatted, encoding: .utf8)
            else {
                Logger().warning("Invalid JSON")
                return nil
            }
            
            Logger().info("Apps: \(string)")
            
            return apps.compactMap { app in
                guard envIds.contains(app.environmentId) else {
                    return nil
                }
                
                var item = app
                item.environmentName = environments[app.environmentId]?.name
                
                return item
            }
        } catch {
            Logger().error("Error fetching apps: \(error)")
            return nil
        }
    }
    
    private func fetchDatabases(envIds: Set<Int>, environments: [Int: CoolifyProjectEnv]) async -> [CoolifyDatabase]? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let url = CoolifyAPIEndpoint.fetchDatabases() else {
            return nil
        }
        
        let store = ValueStore()
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(store.coolifyAPIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let databases = try decoder.decode([CoolifyDatabase].self, from: data)
            
            return databases.compactMap { database in
                guard envIds.contains(database.environmentId) else {
                    return nil
                }
                
                var item = database
                item.environmentName = environments[database.environmentId]?.name
                
                return item
            }
        } catch {
            Logger().error("Error fetching databases: \(error)")
            return nil
        }
    }
}
