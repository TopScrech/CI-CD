import Foundation
import Testing

struct UnitTests {
    private let coolifyAPIKey = "3|Jppioewjujxc0GGYLStnirSvu1DuHFJ9p1hTm4Qs9f133df4"
    
    @Test func fetchProjects() async throws {
        let projects: [CoolifyProject] = try await fetch(from: CoolifyAPIEndpoint.fetchProjects(true))
        
        #expect(!projects.isEmpty)
        
        #expect(projects.allSatisfy {
            !$0.uuid.isEmpty && !$0.name.isEmpty
        })
    }
    
    @Test func fetchApps() async throws {
        let apps: [CoolifyApp] = try await fetch(from: CoolifyAPIEndpoint.fetchApps(true))
        
        #expect(!apps.isEmpty)
        
        #expect(apps.allSatisfy {
            !$0.uuid.isEmpty && $0.environmentId > 0
        })
    }
    
    @Test func fetchDatabases() async throws {
        let databases: [CoolifyDatabase] = try await fetch(from: CoolifyAPIEndpoint.fetchDatabases(true))
        
        #expect(!databases.isEmpty)
        
        #expect(databases.allSatisfy {
            !$0.name.isEmpty && $0.environmentId > 0
        })
    }
    
    private func fetch<T: Decodable>(from endpoint: URL?) async throws -> T {
        guard let url = endpoint else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(coolifyAPIKey)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(T.self, from: data)
    }
}
