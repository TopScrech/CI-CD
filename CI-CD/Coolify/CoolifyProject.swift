import Foundation

struct CoolifyProject: Identifiable, Codable {
    let id: Int
    let uuid: String
    let name: String
    let description: String?
    let environments: [CoolifyProjectEnv]?
}

struct CoolifyProjectEnv: Identifiable, Codable {
    let id: Int
    let projectId: Int?
    let name: String
    let description: String?
    let createdAt: String?
    let updatedAt: String?
}
