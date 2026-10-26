import Foundation

struct GitHubWorkflowJob: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let status: String
    let conclusion: String?
    let htmlURL: URL?
    let steps: [GitHubWorkflowStep]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, status, conclusion, steps
        case htmlURL = "html_url"
    }
}

struct GitHubWorkflowStep: Codable, Identifiable, Hashable {
    let name: String
    let status: String
    let conclusion: String?
    let number: Int
    
    var id: Int { number }
}

struct GitHubWorkflowJobResponse: Codable {
    let jobs: [GitHubWorkflowJob]
}
