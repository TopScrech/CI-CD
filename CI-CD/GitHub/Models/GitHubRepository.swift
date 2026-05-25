import Foundation

struct GitHubRepository: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let fullName: String
    let privateRepository: Bool
    let htmlURL: URL?
    let description: String?
    let defaultBranch: String
    let owner: GitHubRepositoryOwner
    let pushedAt: Date?
    
    var ownerName: String {
        owner.login
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, owner
        case fullName = "full_name"
        case privateRepository = "private"
        case htmlURL = "html_url"
        case defaultBranch = "default_branch"
        case pushedAt = "pushed_at"
    }
}

struct GitHubRepositoryOwner: Codable, Hashable {
    let login: String
}
