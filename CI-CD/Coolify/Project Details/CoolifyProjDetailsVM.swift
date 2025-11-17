import Foundation

@Observable
final class CoolifyProjDetailsVM {
    var apps: [CoolifyApp] = []
    
    func fetchProjects() async {
        let store = ValueStore()
        let path = store.coolifyDomain + "/api/v1/applications"
        
        guard let url = URL(string: path) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(store.coolifyAPIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            } else {
                print("Failed to print JSON")
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            self.apps = try decoder.decode([CoolifyApp].self, from: data)
        } catch {
            print("Error fetching projects:", error)
        }
    }
}
