import Foundation
import OSLog
import AppStoreConnect_Swift_SDK

private let logger = Logger(subsystem: "dev.topscrech.CI-CD", category: "AppVM")

@Observable
final class AppVM {
    var builds: [CiBuildRun] = []
    var workflows: [CiWorkflow] = []
    var primaryRepos: [ScmRepository] = []
    var additionalRepos: [ScmRepository] = []
    var versions: [AppStoreVersion] = []
    
    var iconURL: String?
    
    func appBuilds(_ appId: String, store: ValueStore) async throws {
        guard
            let provider = try await provider(store: store)
        else {
            return
        }
        
        let request = APIEndpoint
            .v1
            .apps
            .id(appId)
            .builds
            .get()
        
        do {
            let builds = try await provider.request(request)
            
            if let buildId = builds.data.first?.id {
                try await appBuildIcon(buildId, store: store)
            }
        } catch {
            logger.error("Failed to fetch app builds: \(error)")
        }
    }
    
    private func appBuildIcon(_ buildId: String, store: ValueStore) async throws {
        guard
            let provider = try await provider(store: store)
        else {
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
            
            guard
                let appStoreIcon = icons.first(where: { $0.attributes?.iconType == .appStore }),
                let urlTemplate = appStoreIcon.attributes?.iconAsset?.templateURL
            else {
                return
            }
            
            let url = urlTemplate
                .replacing("{w}", with: "1024")
                .replacing("{h}", with: "1024")
                .replacing("{f}", with: "png")
            
            iconURL = url
        } catch {
            logger.error("Failed to fetch build icon: \(error)")
        }
    }
    
    func fetchWorkflows(_ id: String, store: ValueStore) async throws {
        guard
            let provider = try await provider(store: store)
        else {
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
            logger.error("Failed to fetch workflows: \(error)")
        }
    }
    
    func fetchBuilds(_ id: String, store: ValueStore) async throws {
        guard
            let provider = try await provider(store: store)
        else {
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
            logger.error("Failed to fetch builds: \(error)")
        }
    }
    
    func startBuild(_ workflowId: String, clean: Bool = false, store: ValueStore) async throws {
        guard
            let provider = try await provider(store: store)
        else {
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
            logger.error("Failed to start build: \(error)")
        }
    }
    
    func primaryRepositories(_ productId: String, store: ValueStore) async throws {
        guard let provider = try await provider(store: store) else {
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
            logger.error("Failed to fetch primary repositories: \(error)")
        }
    }
    
    func additionalRepositories(_ productId: String, store: ValueStore) async throws {
        guard let provider = try await provider(store: store) else {
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
            logger.error("Failed to fetch additional repositories: \(error)")
        }
    }
    
    func getVersions(_ appId: String?, store: ValueStore) async throws {
        guard
            let appId,
            let provider = try await provider(store: store)
        else {
            return
        }
        
        let request = APIEndpoint.v1
            .apps
            .id(appId)
            .appStoreVersions
            .get()
        
        do {
            versions = try await provider.request(request).data
        } catch {
            logger.error("Failed to fetch versions: \(error)")
            throw error
        }
    }
}
