import Foundation

struct CoolifyProject: Identifiable, Codable, Equatable {
    let id: Int
    let uuid: String
    let name: String
    let description: String?
}
