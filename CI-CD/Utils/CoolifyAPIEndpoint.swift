import Foundation

struct CoolifyAPIEndpoint {
    private static func domain(_ isTesting: Bool = false) -> String {
        isTesting ? "https://coolify.bisquit.host" : ValueStore().coolifyDomain
    }
    
    static func deploy(_ appUUID: String) -> URL? {
        URL(string: domain() + "/api/v1/applications/\(appUUID)/start")
    }
    
    static func stop(_ appUUID: String) -> URL? {
        URL(string: domain() + "/api/v1/applications/\(appUUID)/stop")
    }
    
    static func restart(_ appUUID: String) -> URL? {
        URL(string: domain() + "/api/v1/applications/\(appUUID)/start")
    }
    
    static func fetchDeployments(_ appUUID: String) -> URL? {
        URL(string: domain() + "/api/v1/deployments/applications/" + appUUID)
    }
    
    static func proj(_ projUUID: String) -> URL? {
        URL(string: domain() + "/api/v1/projects/" + projUUID)
    }
    
    static func fetchProjEnvironments(_ projUUID: String) -> URL? {
        URL(string: domain() + "/api/v1/projects/\(projUUID)/environments")
    }
    
    static func fetchProjects(_ isTesting: Bool = false) -> URL? {
        URL(string: domain(isTesting) + "/api/v1/projects")
    }
    
    static func fetchDatabases() -> URL? {
        URL(string: domain() + "/api/v1/databases")
    }
    
    static func fetchApps() -> URL? {
        URL(string: domain() + "/api/v1/applications")
    }
}
