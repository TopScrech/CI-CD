import Foundation

struct GitHubWorkflow: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let path: String
    let state: String
    let htmlURL: URL?
    let badgeURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case id, name, path, state
        case htmlURL = "html_url"
        case badgeURL = "badge_url"
    }
}

struct GitHubWorkflowResponse: Codable {
    let totalCount: Int
    let workflows: [GitHubWorkflow]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case workflows
    }
}
