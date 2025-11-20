import Foundation

@Observable
final class CoolifyProjDetailsVM {
    var apps: [CoolifyApp] = []
    var databases: [CoolifyDatabase] = []
    
    var projName = ""
    var projDescription = ""
    var alertRename = false
    
    func rename(_ projUUID: String) async -> CoolifyProject? {
        let store = ValueStore()
        
        let renameProjPath = store.coolifyDomain + "/api/v1/projects/" + projUUID
        
        guard let renameProjURL = URL(string: renameProjPath) else {
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
            print("Error renaming proj:", error.localizedDescription)
            return nil
        }
    }
    
    func load(_ project: CoolifyProject) async {
        guard let environments = await fetchEnvironments(project) else {
            return
        }
        
        let envIds = Set(environments.keys)
        
        async let apps = fetchApps(envIds: envIds, environments: environments)
        async let databases = fetchDatabases(envIds: envIds, environments: environments)
        
        self.apps = await apps ?? []
        self.databases = await databases ?? []
    }
    
    private func fetchEnvironments(_ project: CoolifyProject) async -> [Int: CoolifyProjectEnv]? {
        let store = ValueStore()
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let path = store.coolifyDomain + "/api/v1/projects/\(project.uuid)/environments"
        
        guard let url = URL(string: path) else {
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
            return nil
        }
    }

    func fetchProject(_ uuid: String) async -> CoolifyProject? {
        let store = ValueStore()
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let path = store.coolifyDomain + "/api/v1/projects/" + uuid
        
        guard let url = URL(string: path) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(store.coolifyAPIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return try decoder.decode(CoolifyProject.self, from: data)
        } catch {
            return nil
        }
    }
    
    private func fetchApps(envIds: Set<Int>, environments: [Int: CoolifyProjectEnv]) async -> [CoolifyApp]? {
        let store = ValueStore()
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let path = store.coolifyDomain + "/api/v1/applications"
        
        guard let url = URL(string: path) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(store.coolifyAPIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            var apps = try decoder.decode([CoolifyApp].self, from: data)
            
            apps = apps.compactMap { app in
                guard envIds.contains(app.environmentId) else {
                    return nil
                }
                
                var item = app
                item.environmentName = environments[app.environmentId]?.name
                
                return item
            }
            
            return apps
        } catch {
            return nil
        }
    }
    
    private func fetchDatabases(envIds: Set<Int>, environments: [Int: CoolifyProjectEnv]) async -> [CoolifyDatabase]? {
        let store = ValueStore()
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let path = store.coolifyDomain + "/api/v1/databases"
        
        guard let url = URL(string: path) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(store.coolifyAPIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            var databases = try decoder.decode([CoolifyDatabase].self, from: data)
            
            databases = databases.compactMap { database in
                guard envIds.contains(database.environmentId) else {
                    return nil
                }
                
                var item = database
                item.environmentName = environments[database.environmentId]?.name
                return item
            }
            
            return databases
        } catch {
            return nil
        }
    }
}
