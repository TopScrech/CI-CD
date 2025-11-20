import Foundation

struct CoolifyAPIEndpoint {
    static func deploy(_ appUUID: String) -> URL? {
        URL(string: ValueStore().coolifyDomain + "/api/v1/applications/\(appUUID)/start")
    }
    
    static func stop(_ appUUID: String) -> URL? {
        URL(string: ValueStore().coolifyDomain + "/api/v1/applications/\(appUUID)/stop")
    }
    
    static func restart(_ appUUID: String) -> URL? {
        URL(string: ValueStore().coolifyDomain + "/api/v1/applications/\(appUUID)/start")
    }
    
    static func fetchDeployments(_ appUUID: String) -> URL? {
        URL(string: ValueStore().coolifyDomain + "/api/v1/deployments/applications/" + appUUID)
    }
}
