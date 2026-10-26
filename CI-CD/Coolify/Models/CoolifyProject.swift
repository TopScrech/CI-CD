import Foundation

struct CoolifyProject: Identifiable, Codable {
    let id: Int
    let uuid: String
    let name: String
    let description: String?
}
