import Foundation

struct CoolifyProjectEnv: Identifiable, Codable {
    let id: Int
    let projectId: Int?
    let name: String
    let description: String?
    let createdAt: String?
    let updatedAt: String?
}
