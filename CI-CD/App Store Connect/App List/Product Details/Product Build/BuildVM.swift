import Foundation
import OSLog
import AppStoreConnect_Swift_SDK

@Observable
final class BuildVM {
    private(set) var actions: [CiBuildAction] = []

    func reset() {
        actions = []
    }
    
    func startRebuild(
        of buildId: String,
        in workflowId: String,
        clean: Bool = false,
        store: ValueStore
    ) async throws {
        guard let provider = try await provider(store: store) else {
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
                        buildRun: .init(
                            data: .init(
                                type: .ciBuildRuns, id: buildId
                            )
                        ),
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
            Logger().info("Started build \(build.id)")
        } catch {
            Logger().error("Failed to start rebuild: \(error)")
        }
    }
    
    func buildActions(_ buildId: String, store: ValueStore) async throws {
        guard let provider = try await provider(store: store) else {
            return
        }
        
        let request = APIEndpoint
            .v1
            .ciBuildRuns
            .id(buildId)
            .actions
            .get()
        
        do {
            actions = try await provider.request(request).data.sorted {
                $0.attributes?.name ?? "" < $1.attributes?.name ?? ""
            }
        } catch {
            Logger().error("Failed to fetch build actions: \(error)")
        }
    }
}
