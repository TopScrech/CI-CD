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
    
    static func proj(_ projUUID: String) -> URL? {
        URL(string: ValueStore().coolifyDomain + "/api/v1/projects/" + projUUID)
    }
    
    static func fetchProjEnvironments(_ projUUID: String) -> URL? {
        URL(string: ValueStore().coolifyDomain + "/api/v1/projects/\(projUUID)/environments")
    }
    
    static func fetchProjects() -> URL? {
        URL(string: ValueStore().coolifyDomain + "/api/v1/projects")
    }
    
    static func fetchDatabases() -> URL? {
        URL(string: ValueStore().coolifyDomain + "/api/v1/databases")
    }
    
    static func fetchApps() -> URL? {
        URL(string: ValueStore().coolifyDomain + "/api/v1/applications")
    }
}
