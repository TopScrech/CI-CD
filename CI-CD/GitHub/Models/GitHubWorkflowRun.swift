import Foundation

struct GitHubWorkflowRun: Codable, Identifiable, Hashable {
    let id: Int
    let name: String?
    let displayTitle: String
    let status: String?
    let conclusion: String?
    let event: String
    let headBranch: String?
    let headSha: String
    let htmlURL: URL?
    let createdAt: Date
    let updatedAt: Date
    let runStartedAt: Date?
    let actor: GitHubActor?
    
    enum CodingKeys: String, CodingKey {
        case id, name, status, conclusion, event, actor
        case displayTitle = "display_title"
        case headBranch = "head_branch"
        case headSha = "head_sha"
        case htmlURL = "html_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case runStartedAt = "run_started_at"
    }
}

struct GitHubActor: Codable, Hashable {
    let login: String
}

struct GitHubWorkflowRunResponse: Codable {
    let totalCount: Int
    let workflowRuns: [GitHubWorkflowRun]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case workflowRuns = "workflow_runs"
    }
}
