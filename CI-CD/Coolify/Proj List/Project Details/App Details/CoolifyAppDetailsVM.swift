import OSLog
import ScrechKit

@Observable
final class CoolifyAppDetailsVM {
    var isLoading = true
    var deployments: [CoolifyDeployment] = []
    
    var availableBuildPacks: [CoolifyBuildPack] = []
    var isLoadingBuildPacks = false
    var isPreparingBuildPack = false
    var isSaving = false
    
    var newName = ""
    var newDescription = ""
    var newBuildPack = ""
    
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
        let patchedApp = CoolifyAppUpdateRequest(
            name: newName,
            description: newDescription,
            buildPack: newBuildPack
        )
        
        if store.coolifyDemoMode {
            return CoolifyApp(
                uuid: app.uuid,
                environmentId: app.environmentId,
                repositoryProjectId: app.repositoryProjectId,
                name: patchedApp.name,
                description: patchedApp.description,
                gitRepository: app.gitRepository,
                gitBranch: app.gitBranch,
                buildPack: patchedApp.buildPack,
                fqdn: app.fqdn,
                environmentName: app.environmentName
            )
        }
        
        guard
            let account = store.coolifyAccount, account.isAuthorized,
            let url = CoolifyAPIEndpoint.app(app.uuid, domain: account.domain)
        else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(account.apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            isSaving = true
            
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            request.httpBody = try encoder.encode(patchedApp)
            
            let (_, _) = try await URLSession.shared.data(for: request)
            
            isSaving = false
            return await fetchApp(app.uuid, store: store)
        } catch {
            isSaving = false
            Logger().error("Error renaming app: \(error)")
            return nil
        }
    }
    
    func prepareEditor(for app: CoolifyApp, store: ValueStore) async {
        newName = app.name
        newDescription = app.description ?? ""
        isPreparingBuildPack = true
        newBuildPack = app.buildPack ?? ""
        await fetchBuildPacks(selectedBuildPack: app.buildPack, store: store)
        isPreparingBuildPack = false
    }
    
    func fetchBuildPacks(selectedBuildPack: String?, store: ValueStore) async {
        if store.coolifyDemoMode {
            availableBuildPacks = previewBuildPacks(selectedBuildPack: selectedBuildPack)
            if newBuildPack.isEmpty {
                newBuildPack = availableBuildPacks.first?.rawValue ?? ""
            }
            return
        }
        
        guard let account = store.coolifyAccount, account.isAuthorized else {
            availableBuildPacks = previewBuildPacks(selectedBuildPack: selectedBuildPack)
            return
        }
        
        isLoadingBuildPacks = true
        defer {
            isLoadingBuildPacks = false
        }
        
        for url in openAPIURLs(for: account.domain) {
            do {
                var request = URLRequest(url: url)
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("Bearer \(account.apiKey)", forHTTPHeaderField: "Authorization")
                
                let (data, _) = try await URLSession.shared.data(for: request)
                let buildPacks = try buildPacks(from: data, selectedBuildPack: selectedBuildPack)
                
                availableBuildPacks = buildPacks
                
                if newBuildPack.isEmpty {
                    newBuildPack = buildPacks.first?.rawValue ?? ""
                }
                
                return
            } catch {
                Logger().warning("Error fetching build packs from \(url.absoluteString, privacy: .public): \(error)")
            }
        }
        
        availableBuildPacks = previewBuildPacks(selectedBuildPack: selectedBuildPack)
        
        if newBuildPack.isEmpty {
            newBuildPack = availableBuildPacks.first?.rawValue ?? ""
        }
    }
    
    private func openAPIURLs(for domain: String) -> [URL] {
        var urls = [URL]()
        
        if let instanceURL = CoolifyAPIEndpoint.openAPI(domain: domain) {
            urls.append(instanceURL)
        }
        
        if let docsURL = URL(string: "https://raw.githubusercontent.com/coollabsio/coolify/refs/heads/next/openapi.json") {
            urls.append(docsURL)
        }
        
        return urls
    }
    
    private func buildPacks(from data: Data, selectedBuildPack: String?) throws -> [CoolifyBuildPack] {
        let openAPI = try JSONDecoder().decode(CoolifyOpenAPISpec.self, from: data)
        var identifiers = Set(openAPI.updateBuildPacks)
        
        if let selectedBuildPack {
            identifiers.insert(selectedBuildPack)
        }
        
        let order = ["nixpacks", "static", "dockerfile", "dockercompose", "dockerimage"]
        let sortedIdentifiers = identifiers.sorted { lhs, rhs in
            let lhsIndex = order.firstIndex(of: lhs) ?? .max
            let rhsIndex = order.firstIndex(of: rhs) ?? .max
            
            if lhsIndex == rhsIndex {
                return lhs < rhs
            }
            
            return lhsIndex < rhsIndex
        }
        
        return sortedIdentifiers.map(CoolifyBuildPack.init(rawValue:))
    }
    
    private func previewBuildPacks(selectedBuildPack: String?) -> [CoolifyBuildPack] {
        var identifiers = ["nixpacks", "static", "dockerfile", "dockercompose"]
        
        if let selectedBuildPack, !identifiers.contains(selectedBuildPack) {
            identifiers.append(selectedBuildPack)
        }
        
        return identifiers.map(CoolifyBuildPack.init(rawValue:))
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

private struct CoolifyAppUpdateRequest: Encodable {
    let name: String
    let description: String
    let buildPack: String
}

private struct CoolifyOpenAPISpec: Decodable {
    let paths: [String: CoolifyOpenAPIPath]
    
    var updateBuildPacks: [String] {
        paths["/applications/{uuid}"]?
            .patch?
            .requestBody?
            .content["application/json"]?
            .schema
            .properties["build_pack"]?
            .enumValues ?? []
    }
}

private struct CoolifyOpenAPIPath: Decodable {
    let patch: CoolifyOpenAPIOperation?
}

private struct CoolifyOpenAPIOperation: Decodable {
    let requestBody: CoolifyOpenAPIRequestBody?
}

private struct CoolifyOpenAPIRequestBody: Decodable {
    let content: [String: CoolifyOpenAPIMediaType]
}

private struct CoolifyOpenAPIMediaType: Decodable {
    let schema: CoolifyOpenAPISchema
}

private struct CoolifyOpenAPISchema: Decodable {
    let properties: [String: CoolifyOpenAPISchemaProperty]
}

private struct CoolifyOpenAPISchemaProperty: Decodable {
    let enumValues: [String]?
    
    enum CodingKeys: String, CodingKey {
        case enumValues = "enum"
    }
}
