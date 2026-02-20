import Foundation

struct CoolifyAPIEndpoint {
    private static func resolvedDomain(_ baseDomain: String, isTesting: Bool = false) -> String {
        isTesting ? "https://coolify.bisquit.host" : baseDomain
    }
    
    static func deploy(_ appUUID: String, domain baseDomain: String) -> URL? {
        URL(string: resolvedDomain(baseDomain) + "/api/v1/applications/\(appUUID)/start")
    }
    
    static func stop(_ appUUID: String, domain baseDomain: String) -> URL? {
        URL(string: resolvedDomain(baseDomain) + "/api/v1/applications/\(appUUID)/stop")
    }
    
    static func restart(_ appUUID: String, domain baseDomain: String) -> URL? {
        URL(string: resolvedDomain(baseDomain) + "/api/v1/applications/\(appUUID)/start")
    }
    
    static func fetchDeployments(_ appUUID: String, domain baseDomain: String) -> URL? {
        URL(string: resolvedDomain(baseDomain) + "/api/v1/deployments/applications/" + appUUID)
    }
    
    static func proj(_ projUUID: String, domain baseDomain: String) -> URL? {
        URL(string: resolvedDomain(baseDomain) + "/api/v1/projects/" + projUUID)
    }
    
    static func fetchProjEnvironments(_ projUUID: String, domain baseDomain: String) -> URL? {
        URL(string: resolvedDomain(baseDomain) + "/api/v1/projects/\(projUUID)/environments")
    }
    
    static func fetchProjects(domain baseDomain: String, isTesting: Bool = false) -> URL? {
        URL(string: resolvedDomain(baseDomain, isTesting: isTesting) + "/api/v1/projects")
    }
    
    static func fetchDatabases(domain baseDomain: String, isTesting: Bool = false) -> URL? {
        URL(string: resolvedDomain(baseDomain, isTesting: isTesting) + "/api/v1/databases")
    }
    
    static func fetchApps(domain baseDomain: String, isTesting: Bool = false) -> URL? {
        URL(string: resolvedDomain(baseDomain, isTesting: isTesting) + "/api/v1/applications")
    }
    
    static func app(_ appUUID: String, domain baseDomain: String) -> URL? {
        URL(string: resolvedDomain(baseDomain) + "/api/v1/applications/" + appUUID)
    }
}
