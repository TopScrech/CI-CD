import ScrechKit

@Observable
final class CoolifyAppDetailsVM {
    var deployments: [CoolifyDeployment] = []
    
    func fetchDeployments(_ appUUID: String) async {
        let store = ValueStore()
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let path = store.coolifyDomain + "/api/v1/deployments/applications/" + appUUID
        
        guard let url = URL(string: path) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(store.coolifyAPIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            print(prettyJSON(data) ?? "Invalid JSON")
            
            let response = try decoder.decode(DeploymentResponse.self, from: data)
            deployments = response.deployments
        } catch {
            print("Error fetching deployments:", error)
        }
    }
}
