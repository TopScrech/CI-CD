import Foundation
import OSLog
import ASC

private let logger = Logger(subsystem: "dev.topscrech.CI-CD", category: "AppVM")

@Observable
final class AppVM {
    var builds: [CiBuildRun] = [] {
        didSet {
            guard let latestBuildCache else { return }
            cachedLatestBuild = builds.max { ($0.attributes?.number ?? -1) < ($1.attributes?.number ?? -1) }
            do {
                try latestBuildCache.save(cachedLatestBuild)
            } catch {
                logger.error("Failed to cache latest build: \(error)")
            }
        }
    }
    private var betaStatesByBuildID: [String: [ExternalBetaState]] = [:]
    var latestBuildBetaStates: [ExternalBetaState] {
        guard let latestBuild else { return [] }
        return betaStatesByBuildID[latestBuild.id] ?? []
    }

    private var cachedLatestBuild: CiBuildRun?
    private var latestBuildCache: ProductLatestBuildCache?
    var latestBuild: CiBuildRun? {
        builds.max { ($0.attributes?.number ?? -1) < ($1.attributes?.number ?? -1) } ?? cachedLatestBuild
    }

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

    func restoreLatestBuild(_ productID: String, store: ValueStore) {
        let accountID = store.connectAccount?.id
        guard !store.connectDemoMode, let accountID else {
            latestBuildCache = nil
            cachedLatestBuild = nil
            betaStatesByBuildID = [:]
            builds = []
            return
        }
        guard latestBuildCache?.accountID != accountID || latestBuildCache?.productID != productID else { return }

        latestBuildCache = nil
        builds = []
        let cache = ProductLatestBuildCache(accountID: accountID, productID: productID)
        cachedLatestBuild = cache.load()
        betaStatesByBuildID = cache.loadBetaStates()
        latestBuildCache = cache
    }

    func fetchBuilds(_ id: String, store: ValueStore) async throws {
        restoreLatestBuild(id, store: store)
        guard let accountID = store.connectAccount?.id, !store.connectDemoMode,
              let provider = try await provider(store: store) else { return }

        let request = APIEndpoint.v1
            .ciProducts
            .id(id)
            .buildRuns
            .get(
                parameters: .init(sort: [.minusnumber], include: [.workflow])
            )
        
        do {
            let fetchedBuilds = try await provider.request(request).data
            try Task.checkCancellation()
            guard store.connectAccount?.id == accountID, !store.connectDemoMode,
                  latestBuildCache?.productID == id else { return }
            builds = fetchedBuilds.sorted {
                ($0.attributes?.number ?? -1) < ($1.attributes?.number ?? -1)
            }

            guard let build = latestBuild else { return }
            do {
                let betaRequest = APIEndpoint.v1.ciBuildRuns.id(build.id).builds.get(
                    parameters: .init(include: [.buildBetaDetail])
                )
                var states: [ExternalBetaState] = []
                for try await page in provider.paged(betaRequest) {
                    var includedStates: [String: ExternalBetaState] = [:]
                    for item in page.included ?? [] {
                        if case .buildBetaDetail(let detail) = item,
                           let state = detail.attributes?.externalBuildState {
                            includedStates[detail.id] = state
                        }
                    }
                    for uploadedBuild in page.data {
                        let detailID = uploadedBuild.relationships?.buildBetaDetail?.data?.id ?? uploadedBuild.id
                        if let state = includedStates[detailID] {
                            states.append(state)
                        } else {
                            // Xcode Cloud can return empty included details even when the direct endpoint has review state
                            let detail = try await provider.request(
                                APIEndpoint.v1.builds.id(uploadedBuild.id).buildBetaDetail.get()
                            ).data
                            if let state = detail.attributes?.externalBuildState {
                                states.append(state)
                            }
                        }
                    }
                }
                try Task.checkCancellation()
                guard store.connectAccount?.id == accountID, !store.connectDemoMode,
                      latestBuildCache?.productID == id, latestBuild?.id == build.id else { return }
                betaStatesByBuildID = [build.id: states]
                try latestBuildCache?.saveBetaStates(states, for: build.id)
            } catch is CancellationError {
                return
            } catch {
                logger.error("Failed to refresh latest build beta review state: \(error)")
            }
        } catch is CancellationError {
            return
        } catch {
            logger.error("Failed to fetch builds: \(error)")
        }
    }
    
    func startBuild(_ workflowId: String, clean: Bool = false, store: ValueStore) async throws {
        let accountID = store.connectAccount?.id
        let productID = latestBuildCache?.productID
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
            try Task.checkCancellation()
            guard store.connectAccount?.id == accountID, !store.connectDemoMode,
                  latestBuildCache?.productID == productID else { return }
            builds.append(build)
        } catch {
            logger.error("Failed to start build: \(error)")
        }
    }
    
    func restoreRepositories(_ productID: String, store: ValueStore) {
        guard let accountID = store.connectAccount?.id, !store.connectDemoMode else {
            primaryRepos = []
            additionalRepos = []
            return
        }

        let cache = ProductRepositoryCache(accountID: accountID, productID: productID)
        primaryRepos = cache.load(.primary) ?? []
        additionalRepos = cache.load(.additional) ?? []
    }

    func primaryRepositories(_ productId: String, store: ValueStore) async throws {
        guard let accountID = store.connectAccount?.id, !store.connectDemoMode else { return }
        let cache = ProductRepositoryCache(accountID: accountID, productID: productId)

        do {
            guard let provider = try await provider(store: store) else { return }
            let request = APIEndpoint.v1.ciProducts.id(productId).primaryRepositories.get()
            var repositories: [ScmRepository] = []
            for try await page in provider.paged(request) {
                repositories.append(contentsOf: page.data)
            }
            try Task.checkCancellation()
            guard store.connectAccount?.id == accountID, !store.connectDemoMode else { return }

            primaryRepos = repositories
            try cache.save(repositories, for: .primary)
        } catch is CancellationError {
            return
        } catch {
            logger.error("Failed to refresh primary repositories: \(error)")
        }
    }

    func additionalRepositories(_ productId: String, store: ValueStore) async throws {
        guard let accountID = store.connectAccount?.id, !store.connectDemoMode else { return }
        let cache = ProductRepositoryCache(accountID: accountID, productID: productId)

        do {
            guard let provider = try await provider(store: store) else { return }
            let request = APIEndpoint.v1.ciProducts.id(productId).additionalRepositories.get()
            var repositories: [ScmRepository] = []
            for try await page in provider.paged(request) {
                repositories.append(contentsOf: page.data)
            }
            try Task.checkCancellation()
            guard store.connectAccount?.id == accountID, !store.connectDemoMode else { return }

            additionalRepos = repositories
            try cache.save(repositories, for: .additional)
        } catch is CancellationError {
            return
        } catch {
            logger.error("Failed to refresh additional repositories: \(error)")
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
