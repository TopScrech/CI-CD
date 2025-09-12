import Foundation
import AppStoreConnect_Swift_SDK

@Observable
final class BuildVM {
    var actions: [CiBuildAction] = []
    
    func startRebuild(
        of buildId: String,
        in workflowId: String,
        clean: Bool = false
    ) async throws {
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
            print(build)
        } catch {
            print(error)
        }
    }
    
    func buildActions(_ buildId: String) async throws {
        guard let provider = try await provider() else {
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
            print(error)
        }
    }
}
