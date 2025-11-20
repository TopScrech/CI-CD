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
    let gitRepository: String?
    let gitBranch: String?
    let fqdn: String?
    
    /// Helps to link apps to their parent proj
    var environmentName: String?
    
    var gitRepoURL: URL? {
        if let gitRepository {
            URL(string: "https://github.com/" + gitRepository)
        } else {
            nil
        }
    }
}
