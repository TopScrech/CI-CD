import Foundation
import AppStoreConnect_Swift_SDK

@Observable
final class BuildVM {
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
            let response = try await provider.request(request).data
            print(response)
        } catch {
            print(error)
        }
    }
}
