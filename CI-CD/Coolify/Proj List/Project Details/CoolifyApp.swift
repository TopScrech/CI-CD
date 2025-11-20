import Foundation

struct CoolifyApp: Identifiable, Decodable {
    var id: String {
        uuid
    }
    
    let uuid: String
    let environmentId: Int
    let repositoryProjectId: Int
    let name: String
    let description: String?
#warning("Doesn't exist or has a different name")
    let gitFullUrl: String?
    let fqdn: String?
    
    /// Helps to link apps to their parent proj
    var environmentName: String?
}
