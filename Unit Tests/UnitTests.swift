import Foundation
import Testing

struct UnitTests {
    private let coolifyAPIKey = "3|Jppioewjujxc0GGYLStnirSvu1DuHFJ9p1hTm4Qs9f133df4"
    
    @Test func fetchProjects() async throws {
        guard let url = CoolifyAPIEndpoint.fetchProjects(true) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(coolifyAPIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            printPrettyJSON(data)
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let _ = try decoder.decode([CoolifyProject].self, from: data)
        } catch {
            print("Error fetching or decoding projects:", error)
        }
    }
    
    private func printPrettyJSON(_ data: Data) {
        guard
            let object = try? JSONSerialization.jsonObject(with: data),
            let prettyData = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
            let prettyString = String(data: prettyData, encoding: .utf8)
        else {
            print("⛔️ Invalid JSON")
            return
        }
        
        print(prettyString)
    }
}
