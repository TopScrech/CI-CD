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
        guard let accountID = store.connectAccount?.id, !store.connectDemoMode else {
            iconURL = nil
            return
        }

        let cacheKey = "connect.iconURL.\(accountID).\(appId)"
        iconURL = UserDefaults.standard.string(forKey: cacheKey)

        guard let provider = try await provider(store: store) else {
            return
        }

        do {
            let builds = try await provider.request(
                APIEndpoint.v1.apps.id(appId).builds.get()
            )
            try Task.checkCancellation()

            guard let buildID = builds.data.first?.id else {
                return
            }

            let icons = try await provider.request(
                APIEndpoint.v1.builds.id(buildID).icons.get()
            ).data
            try Task.checkCancellation()

            guard
                store.connectAccount?.id == accountID,
                let appStoreIcon = icons.first(where: { $0.attributes?.iconType == .appStore }),
                let urlTemplate = appStoreIcon.attributes?.iconAsset?.templateURL
            else {
                return
            }

            let url = urlTemplate
                .replacing("{w}", with: "1024")
                .replacing("{h}", with: "1024")
                .replacing("{f}", with: "png")

            UserDefaults.standard.set(url, forKey: cacheKey)
            iconURL = url
        } catch is CancellationError {
            return
        } catch {
            logger.error("Failed to refresh app icon: \(error)")
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
    
    func fetchWorkflow(_ id: String, store: ValueStore) async throws -> CiWorkflow {
        if store.connectDemoMode {
            guard let workflow = workflows.first(where: { $0.id == id }) else {
                throw URLError(.resourceUnavailable)
            }
            return workflow
        }

        guard let provider = try await provider(store: store) else {
            throw URLError(.userAuthenticationRequired)
        }

        let workflow = try await provider.request(APIEndpoint.v1.ciWorkflows.id(id).get(parameters: .init(include: [.xcodeVersion, .macOsVersion]))).data
        if let index = workflows.firstIndex(where: { $0.id == id }) {
            workflows[index] = workflow
        }
        return workflow
    }

    func updateWorkflow(_ workflow: CiWorkflow, name: String, description: String, restrictEditing: Bool, isClean: Bool, xcodeVersionID: String?, macOSVersionID: String?, store: ValueStore) async throws {
        let updated: CiWorkflow

        if store.connectDemoMode {
            var draft = workflow
            if draft.attributes == nil {
                draft.attributes = .init()
            }
            draft.attributes?.name = name
            draft.attributes?.description = description
            draft.attributes?.isLockedForEditing = restrictEditing
            draft.attributes?.isClean = isClean
            if draft.relationships == nil {
                draft.relationships = .init()
            }
            if let xcodeVersionID {
                draft.relationships?.xcodeVersion = .init(data: .init(type: .ciXcodeVersions, id: xcodeVersionID))
            }
            if let macOSVersionID {
                draft.relationships?.macOsVersion = .init(data: .init(type: .ciMacOsVersions, id: macOSVersionID))
            }
            updated = draft
        } else {
            guard let provider = try await provider(store: store) else {
                throw URLError(.userAuthenticationRequired)
            }

            var relationships = CiWorkflowUpdateRequest.Data.Relationships()
            if let xcodeVersionID {
                relationships.xcodeVersion = .init(data: .init(type: .ciXcodeVersions, id: xcodeVersionID))
            }
            if let macOSVersionID {
                relationships.macOsVersion = .init(data: .init(type: .ciMacOsVersions, id: macOSVersionID))
            }

            updated = try await provider.request(
                APIEndpoint.v1.ciWorkflows.id(workflow.id).patch(
                    .init(data: .init(
                        type: .ciWorkflows,
                        id: workflow.id,
                        attributes: .init(
                            name: name,
                            description: description,
                            isLockedForEditing: restrictEditing,
                            isClean: isClean
                        ),
                        relationships: relationships
                    ))
                )
            ).data
        }

        if let index = workflows.firstIndex(where: { $0.id == workflow.id }) {
            workflows[index] = updated
        }
    }

    func renameWorkflow(_ workflow: CiWorkflow, name: String, description: String, store: ValueStore) async throws {
        let updated: CiWorkflow

        if store.connectDemoMode {
            var draft = workflows.first { $0.id == workflow.id } ?? workflow
            if draft.attributes == nil {
                draft.attributes = .init()
            }
            draft.attributes?.name = name
            draft.attributes?.description = description
            updated = draft
        } else {
            guard let provider = try await provider(store: store) else {
                throw URLError(.userAuthenticationRequired)
            }

            updated = try await provider.request(
                APIEndpoint.v1.ciWorkflows.id(workflow.id).patch(
                    .init(data: .init(
                        type: .ciWorkflows,
                        id: workflow.id,
                        attributes: .init(name: name, description: description)
                    ))
                )
            ).data
        }

        if let index = workflows.firstIndex(where: { $0.id == workflow.id }) {
            workflows[index] = updated
        }
    }

    func deleteWorkflow(_ id: String, store: ValueStore) async throws {
        if !store.connectDemoMode {
            guard let provider = try await provider(store: store) else {
                throw URLError(.userAuthenticationRequired)
            }

            try await provider.request(APIEndpoint.v1.ciWorkflows.id(id).delete)
        }

        workflows.removeAll { $0.id == id }
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
