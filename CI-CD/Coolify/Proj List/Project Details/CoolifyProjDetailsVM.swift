import OSLog
import ScrechKit

private let logger = Logger(subsystem: "dev.topscrech.CI-CD", category: "CoolifyProjDetailsVM")

@Observable
final class CoolifyProjDetailsVM {
    var apps: [CoolifyApp] = []
    var databases: [CoolifyDatabase] = []
    private var loadedAccount: CoolifyAccountSnapshot?
    private var loadedProjectUUID: String?
    private var latestRequestID = UUID()
    
    var projName = ""
    var projDescription = ""
    var alertRename = false
    
    func rename(_ projUUID: String, store: ValueStore) async -> CoolifyProject? {
        if store.coolifyDemoMode {
            return CoolifyProject(
                id: Preview.coolifyProj.id,
                uuid: projUUID,
                name: projName,
                description: projDescription
            )
        }

        guard let account = store.coolifyAccount, account.isAuthorized else {
            return nil
        }
        
        guard let renameProjURL = CoolifyAPIEndpoint.proj(projUUID, domain: account.domain) else {
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
        renameRequest.setValue("Bearer \(account.apiKey)", forHTTPHeaderField: "Authorization")
        renameRequest.httpBody = body
        
        do {
            _ = try await CoolifyTransport.data(for: renameRequest, account: account)
            return await fetchProject(projUUID, store: store)
        } catch {
            logger.error("Error renaming proj: \(error)")
            return nil
        }
    }
    
    func load(_ projUUID: String, store: ValueStore) async {
        let requestID = UUID()
        latestRequestID = requestID
        let account = store.coolifyAccount

        if loadedAccount != account || loadedProjectUUID != projUUID {
            apps = []
            databases = []
            loadedAccount = account
            loadedProjectUUID = projUUID

            if let account, account.isAuthorized, !account.demoMode {
                apps = CoolifyProjectAppsCache(accountID: account.id, domain: account.domain, projectUUID: projUUID).load() ?? []
            }
        }

        if store.coolifyDemoMode {
            apps = Preview.coolifyApps
            databases = Preview.coolifyDatabases
            return
        }

        guard let account, account.isAuthorized else {
            apps = []
            databases = []
            return
        }

        guard let environments = await fetchEnvironments(projUUID, account: account),
              !Task.isCancelled, latestRequestID == requestID, store.coolifyAccount == account else { return }

        let envIds = Set(environments.keys)
        async let fetchedApps = fetchApps(envIds: envIds, environments: environments, account: account)
        async let fetchedDatabases = fetchDatabases(envIds: envIds, environments: environments, account: account)
        let (apps, databases) = await (fetchedApps, fetchedDatabases)

        guard !Task.isCancelled, latestRequestID == requestID, store.coolifyAccount == account else { return }

        if let apps {
            self.apps = apps
            do {
                try CoolifyProjectAppsCache(accountID: account.id, domain: account.domain, projectUUID: projUUID).save(apps)
            } catch {
                logger.error("Failed to cache Coolify apps: \(error)")
            }
        }

        if let databases {
            self.databases = databases
        }
    }

    private func fetchEnvironments(_ projUUID: String, account: CoolifyAccountSnapshot) async -> [Int: CoolifyProjectEnv]? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let url = CoolifyAPIEndpoint.fetchProjEnvironments(projUUID, domain: account.domain) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(account.apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await CoolifyTransport.data(for: request, account: account)
            let envs = try decoder.decode([CoolifyProjectEnv].self, from: data)
            
            return Dictionary(uniqueKeysWithValues: envs.map { ($0.id, $0) })
        } catch {
            logger.error("Error fetching environments: \(error)")
            return nil
        }
    }
    
    func fetchProject(_ projUUID: String, store: ValueStore) async -> CoolifyProject? {
        guard let account = store.coolifyAccount, account.isAuthorized else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let url = CoolifyAPIEndpoint.proj(projUUID, domain: account.domain) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(account.apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await CoolifyTransport.data(for: request, account: account)
            return try decoder.decode(CoolifyProject.self, from: data)
        } catch {
            logger.error("Error fetching project: \(error)")
            return nil
        }
    }
    
    private func fetchApps(envIds: Set<Int>, environments: [Int: CoolifyProjectEnv], account: CoolifyAccountSnapshot) async -> [CoolifyApp]? {
        guard let url = CoolifyAPIEndpoint.fetchApps(domain: account.domain) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(account.apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await CoolifyTransport.data(for: request, account: account)
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            logger.info("Fetched apps: \(prettyJSON(data) ?? "Invalid JSON")")
            
            let apps = try decoder.decode([CoolifyApp].self, from: data)
            
            guard
                let object = try? JSONSerialization.jsonObject(with: data),
                let formatted = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
                let string = String(data: formatted, encoding: .utf8)
            else {
                logger.warning("Invalid JSON")
                return nil
            }
            
            logger.info("Apps: \(string)")
            
            return apps.compactMap { app in
                guard envIds.contains(app.environmentId) else {
                    return nil
                }
                
                var item = app
                item.environmentName = environments[app.environmentId]?.name
                
                return item
            }
        } catch {
            logger.error("Error fetching apps: \(error)")
            return nil
        }
    }
    
    private func fetchDatabases(envIds: Set<Int>, environments: [Int: CoolifyProjectEnv], account: CoolifyAccountSnapshot) async -> [CoolifyDatabase]? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let url = CoolifyAPIEndpoint.fetchDatabases(domain: account.domain) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(account.apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await CoolifyTransport.data(for: request, account: account)
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
            logger.error("Error fetching databases: \(error)")
            return nil
        }
    }
}
