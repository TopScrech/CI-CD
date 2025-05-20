import Foundation
import AppStoreConnect_Swift_SDK

@Observable
final class ProductVM {
    var builds: [CiBuildRun] = []
    var workflows: [CiWorkflow] = []
    
    func fetchIconUrl(_ bundleId: String?) async throws -> URL? {
        guard let bundleId else {
            return nil
        }
        
        let urlString = "https://itunes.apple.com/lookup?bundleId=" + bundleId
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL:", urlString)
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let result = try JSONDecoder().decode(Welcome.self, from: data)
        
        guard
            let resultUrlString = result.results.first?.artworkUrl512
        else {
            print("No artworkUrl512 found for", bundleId)
            return nil
        }
        
        return URL(string: resultUrlString)
    }
    
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
            .get()
        
        do {
            builds = try await provider.request(request).data
        } catch {
            print(error)
        }
    }
    
    func startBuild(_ id: String) async throws {
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
        
        do {
            let response = try await provider.request(request).data
            print(response)
        } catch {
            print(error)
        }
    }
}
