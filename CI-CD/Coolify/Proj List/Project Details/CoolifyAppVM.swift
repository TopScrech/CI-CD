import Foundation

@Observable
final class CoolifyAppVM {
    func deploy(_ appUUID: String, force: Bool = false) async {
        let store = ValueStore()
        let path = store.coolifyDomain + "/api/v1/applications/\(appUUID)/start"
        
        guard let url = URL(string: path) else {
            return
        }
        
        let queryItems = [
            URLQueryItem(name: "force", value: force.description)
        ]
        
        var request = URLRequest(url: url.appending(queryItems: queryItems))
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(store.coolifyAPIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, _) = try await URLSession.shared.data(for: request)
            print("Successfully queued a deployment")
        } catch {
            print("Error fetching projects:", error)
        }
    }
    
    func stop(_ appUUID: String) async {
        let store = ValueStore()
        let path = store.coolifyDomain + "/api/v1/applications/\(appUUID)/stop"
        
        guard let url = URL(string: path) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(store.coolifyAPIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, _) = try await URLSession.shared.data(for: request)
            print("Successfully restarted app")
        } catch {
            print("Error startig app:", error)
        }
    }
    
    func restart(_ appUUID: String) async {
        let store = ValueStore()
        let path = store.coolifyDomain + "/api/v1/applications/\(appUUID)/restart"
        
        guard let url = URL(string: path) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(store.coolifyAPIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, _) = try await URLSession.shared.data(for: request)
            print("Successfully restarted an app")
        } catch {
            print("Error restarting app:", error)
        }
    }
}
