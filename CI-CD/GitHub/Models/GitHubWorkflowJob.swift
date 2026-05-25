import Foundation

struct GitHubWorkflowJob: Codable, Identifiable, Hashable {
    let id: Int
    let runID: Int
    let name: String
    let status: String
    let conclusion: String?
    let startedAt: Date?
    let completedAt: Date?
    let htmlURL: URL?
    let steps: [GitHubWorkflowStep]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, status, conclusion, steps
        case runID = "run_id"
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case htmlURL = "html_url"
    }
}

struct GitHubWorkflowStep: Codable, Identifiable, Hashable {
    let name: String
    let status: String
    let conclusion: String?
    let number: Int
    let startedAt: Date?
    let completedAt: Date?
    
    var id: Int { number }
    
    enum CodingKeys: String, CodingKey {
        case name, status, conclusion, number
        case startedAt = "started_at"
        case completedAt = "completed_at"
    }
}

struct GitHubWorkflowJobResponse: Codable {
    let totalCount: Int
    let jobs: [GitHubWorkflowJob]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case jobs
    }
}
