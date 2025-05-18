import Foundation

@Observable
final class ProductVM {
    private(set) var builds: [CIBuildRun] = []
    private(set) var workflows: [CIWorkflow] = []
    
    func fetchWorkflows(_ id: String) async throws {
        let subdir = "/v1/ciProducts/\(id)/workflows"
        let urlString = "https://api.appstoreconnect.apple.com" + subdir
        
        let jwt = try ConnectHelper.generateJWT(subdir)
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code:", httpResponse.statusCode)
                
                if httpResponse.statusCode != 200 {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response"
                    print("Server Response:", responseString)
                    
                    throw URLError(.badServerResponse)
                }
            } else {
                print("Error: no response")
            }
            
            let decoder = JSONDecoder()
            
            do {
                workflows = try decoder.decode(CIWorkflowsResponse.self, from: data).data
            } catch {
                print("Decoding Error:", error)
            }
        } catch {
            print("Error:", error)
        }
    }
    
    func fetchBuilds(_ id: String) async throws {
        let subdir = "/v1/ciProducts/\(id)/buildRuns"
        let urlString = "https://api.appstoreconnect.apple.com" + subdir
        
        let jwt = try ConnectHelper.generateJWT(subdir)
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code:", httpResponse.statusCode)
                
                if httpResponse.statusCode != 200 {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response"
                    print("Server Response:", responseString)
                    
                    throw URLError(.badServerResponse)
                }
            } else {
                print("Error: no response")
            }
            
            let decoder = JSONDecoder()
            
            do {
                let buildRuns = try decoder.decode(CIBuildRunsResponse.self, from: data)
                
                builds = buildRuns.data
            } catch {
                print("Decoding Error:", error)
            }
        } catch {
            print("Error:", error)
        }
    }
}
