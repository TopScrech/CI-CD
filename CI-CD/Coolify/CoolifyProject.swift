import Foundation

struct CoolifyProject: Identifiable, Codable {
    let id: Int
    let uuid: String
    let name: String
    let description: String?
    let environments: [CoolifyProjectEnvironment]?
}

struct CoolifyProjectEnvironment: Identifiable, Codable {
    let id: Int
    let name: String
    let projectId: Int
    let createdAt: String
    let updatedAt: String
    let description: String
}
