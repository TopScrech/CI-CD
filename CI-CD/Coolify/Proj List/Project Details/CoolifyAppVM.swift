import Foundation
import OSLog

@Observable
final class CoolifyAppVM {
    func deploy(_ appUUID: String, force: Bool = false) async {
        let store = ValueStore()
        
        guard let url = CoolifyAPIEndpoint.deploy(appUUID) else {
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
            Logger().info("Successfully queued a deployment")
        } catch {
            Logger().error("Error fetching projects: \(error)")
        }
    }
    
    func stop(_ appUUID: String) async {
        let store = ValueStore()
        
        guard let url = CoolifyAPIEndpoint.stop(appUUID) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(store.coolifyAPIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, _) = try await URLSession.shared.data(for: request)
            Logger().info("Successfully restarted app")
        } catch {
            Logger().error("Error startig app: \(error)")
        }
    }
    
    func restart(_ appUUID: String) async {
        let store = ValueStore()
        
        guard let url = CoolifyAPIEndpoint.restart(appUUID) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(store.coolifyAPIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, _) = try await URLSession.shared.data(for: request)
            Logger().info("Successfully restarted an app")
        } catch {
            Logger().error("Error restarting app: \(error)")
        }
    }
}
