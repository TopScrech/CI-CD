import Foundation
import AppStoreConnect_Swift_SDK

@Observable
final class ProductVM {
    var builds: [CiBuildRun] = []
    var workflows: [CiWorkflow] = []
    var primaryRepos: [ScmRepository] = []
    var additionalRepos: [ScmRepository] = []
    
    var iconUrl: String?
    
    func appBuilds(_ appId: String) async throws {
        guard let provider = try await provider() else {
            return
        }
        
        let request = APIEndpoint
            .v1
            .apps
            .id(appId)
            .builds
            .get()
        
        do {
            let builds = try await provider.request(request).data
            
            if let buildId = builds.first?.id {
                try await appBuildIcon(buildId)
            }
        } catch {
            print(error)
        }
    }
    
    private func appBuildIcon(_ buildId: String) async throws {
        guard let provider = try await provider() else {
            return
        }
        
        let request = APIEndpoint
            .v1
            .builds
            .id(buildId)
            .icons
            .get()
        
        do {
            let icons = try await provider.request(request).data
            
            if let appStoreIcon = icons.first(where: { $0.attributes?.iconType == .appStore }) {
                if let urlTemplate = appStoreIcon.attributes?.iconAsset?.templateURL {
                    let url = urlTemplate
                        .replacingOccurrences(of: "{w}", with: "1024")
                        .replacingOccurrences(of: "{h}", with: "1024")
                        .replacingOccurrences(of: "{f}", with: "png")
                    
                    iconUrl = url
                    print("App Store Icon URL:", url)
                }
            }
        } catch {
            print(error)
        }
    }
    
//    func fetchIconUrl(_ bundleId: String?) async throws -> URL? {
//        guard let bundleId else {
//            return nil
//        }
//        
//        let urlString = "https://itunes.apple.com/lookup?bundleId=" + bundleId
//        
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL:", urlString)
//            throw URLError(.badURL)
//        }
//        
//        let (data, _) = try await URLSession.shared.data(from: url)
//        let result = try JSONDecoder().decode(Welcome.self, from: data)
//        
//        guard
//            let resultUrlString = result.results.first?.artworkUrl512
//        else {
//            print("No artworkUrl512 found for", bundleId)
//            return nil
//        }
//        
//        return URL(string: resultUrlString)
//    }
    
    func fetchWorkflows(_ id: String) async throws {
        guard let provider = try await provider() else {
            return
        }
        
        let request = APIEndpoint.v1
            .ciProducts
            .id(id)
            .workflows
            .get()
        
        do {
            workflows = try await provider.request(request).data
        } catch {
            print(error)
        }
    }
    
    func fetchBuilds(_ id: String) async throws {
        guard let provider = try await provider() else {
            return
        }
        
        let request = APIEndpoint.v1
            .ciProducts
            .id(id)
            .buildRuns
            .get(
                parameters: .init(include: [.workflow])
            )
        
        do {
            builds = try await provider.request(request).data
        } catch {
            print(error)
        }
    }
    
    func startBuild(_ workflowId: String, clean: Bool = false) async throws {
        guard let provider = try await provider() else {
            return
        }
        
        let request = APIEndpoint
            .v1
            .ciBuildRuns
            .post(
                .init(data: .init(
                    type: .ciBuildRuns,
                    attributes: .init(
                        isClean: clean
                    ),
                    relationships: .init(
                        workflow: .init(
                            data: .init(
                                type: .ciWorkflows,
                                id: workflowId
                            )
                        )
                    )
                ))
            )
        
        do {
            let build = try await provider.request(request).data
            builds.append(build)
        } catch {
            print(error)
        }
    }
    
    func primaryRepositories(_ productId: String) async throws {
        guard let provider = try await provider() else {
            return
        }
        
        let request = APIEndpoint.v1
            .ciProducts
            .id(productId)
            .primaryRepositories
            .get()
        
        do {
            primaryRepos = try await provider.request(request).data
        } catch {
            print(error)
        }
    }
    
    func additionalRepositories(_ productId: String) async throws {
        guard let provider = try await provider() else {
            return
        }
        
        let request = APIEndpoint.v1
            .ciProducts
            .id(productId)
            .additionalRepositories
            .get()
        
        do {
            additionalRepos = try await provider.request(request).data
        } catch {
            print(error)
        }
    }
}
