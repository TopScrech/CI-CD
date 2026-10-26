import Foundation

struct GitHubWorkflow: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let path: String
    let state: String
    let htmlURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case id, name, path, state
        case htmlURL = "html_url"
    }
}

struct GitHubWorkflowResponse: Codable {
    let workflows: [GitHubWorkflow]
}
