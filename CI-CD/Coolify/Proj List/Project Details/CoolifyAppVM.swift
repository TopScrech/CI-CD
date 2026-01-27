import Foundation
import OSLog

@Observable
final class CoolifyAppVM {
    func deploy(_ appUUID: String, force: Bool = false, store: ValueStore) async {
        guard let account = store.coolifyAccount, account.isAuthorized else {
            return
        }
        
        guard let url = CoolifyAPIEndpoint.deploy(appUUID, domain: account.domain) else {
            return
        }
        
        let queryItems = [
            URLQueryItem(name: "force", value: force.description)
        ]
        
        var request = URLRequest(url: url.appending(queryItems: queryItems))
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(account.apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, _) = try await URLSession.shared.data(for: request)
            Logger().info("Successfully queued a deployment")
        } catch {
            Logger().error("Error fetching projects: \(error)")
        }
    }
    
    func stop(_ appUUID: String, store: ValueStore) async {
        guard let account = store.coolifyAccount, account.isAuthorized else {
            return
        }
        
        guard let url = CoolifyAPIEndpoint.stop(appUUID, domain: account.domain) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(account.apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, _) = try await URLSession.shared.data(for: request)
            Logger().info("Successfully restarted app")
        } catch {
            Logger().error("Error startig app: \(error)")
        }
    }
    
    func restart(_ appUUID: String, store: ValueStore) async {
        guard let account = store.coolifyAccount, account.isAuthorized else {
            return
        }
        
        guard let url = CoolifyAPIEndpoint.restart(appUUID, domain: account.domain) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(account.apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, _) = try await URLSession.shared.data(for: request)
            Logger().info("Successfully restarted an app")
        } catch {
            Logger().error("Error restarting app: \(error)")
        }
    }
}
