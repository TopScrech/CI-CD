import Foundation
import AppStoreConnect_Swift_SDK

@Observable
final class BuildVM {
    var actions: [CiBuildAction] = []
    
    func startBuild(_ workflowId: String) async throws {
        guard let provider = try await provider() else {
            return
        }
        
        let request = APIEndpoint
            .v1
            .ciBuildRuns
            .post(
                .init(data: .init(
                    type: .ciBuildRuns,
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
            print(build)
        } catch {
            print(error)
        }
    }
    
    func buildActions(_ buildId: String) async throws {
        guard let provider = try await provider() else {
            return
        }
        
        // https://api.appstoreconnect.apple.com/v1/ciBuildRuns/593f017b-315f-4660-80d1-5e7f1199b9c1/relationships/actions
        let request = APIEndpoint
            .v1
            .ciBuildRuns
            .id(buildId)
            .actions
            .get()
        
        do {
            actions = try await provider.request(request).data
        } catch {
            print(error)
        }
    }
}
