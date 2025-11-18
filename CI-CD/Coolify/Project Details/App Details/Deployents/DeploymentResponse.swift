import SwiftUI

struct DeploymentResponse: Decodable {
    let count: Int
    let deployments: [CoolifyDeployment]
}

struct CoolifyDeployment: Identifiable, Decodable {
    var id: Int
    let uuid: String?
    let status: DeploymentStatus
    let createdAt: String?
    let updatedAt: String?
    let commitSha: String?
    let branch: String?
    let message: String?
}

enum DeploymentStatus: String, Decodable {
    case finished,
         failed,
         queued,
         running,
         canceled,
         unknown
    
    var color: Color {
        switch self {
        case .finished: .green
        case .failed: .red
        default: .gray
        }
    }
}
