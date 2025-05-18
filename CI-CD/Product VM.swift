import Foundation
import AppStoreConnect_Swift_SDK

@Observable
final class ProductVM {
    private(set) var builds: [CiBuildRun] = []
    //    private(set) var workflows: [CIWorkflow] = []
    
    func fetchWorkflows(_ id: String) async throws {
        //        let subdir = "/v1/ciProducts/\(id)/workflows"
        
    }
    
    func fetchBuilds(_ id: String) async throws {
        do {
            guard let provider = try await provider() else {
                return
            }
            
            let request = APIEndpoint.v1
                .ciProducts
                .id(id)
                .buildRuns
                .get()
            
            builds = try await provider.request(request).data
        } catch {
            print(error)
        }
    }
    
    func startBuild(_ id: String) async throws {
        do {
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
                                    id: id
                                )
                            )
                        )
                    ))
                )
            
            let response = try await provider.request(request).data
            print(response)
        } catch {
            print(error)
        }
    }
}
