import Foundation

@Observable
final class CoolifyProjListVM {
    var projects: [CoolifyProject] = []
    
    func fetchProjects() async {
        let store = ValueStore()
        let path = store.coolifyDomain + "/api/v1/projects"
        
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
            
            self.projects = try JSONDecoder().decode([CoolifyProject].self, from: data)
        } catch {
            print("Error fetching projects:", error)
        }
    }
}
