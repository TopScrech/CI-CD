import Foundation
import AppStoreConnect_Swift_SDK

@Observable
final class BuildVM {
    func startBuild(_ id: String) async throws {
        guard let provider = try await provider() else {
            return
        }
        
        let request = APIEndpoint
            .v1
            .ciBuildRuns
            .post(.init(data: .init(type: .ciBuildRuns)))
        
        do {
            let response = try await provider.request(request).data
            print(response)
        } catch {
            print(error)
        }
    }
}
