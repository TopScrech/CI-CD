import Foundation

struct ConnectWebBuildTiming: Codable, Equatable {
    let id: String
    let number: Int
    let state: String
    let startedAt: Date?
    let finishedAt: Date?

    var isComplete: Bool {
        ["succeeded", "failed", "error", "cancelled", "never-ran"].contains(state)
    }

    enum CodingKeys: String, CodingKey {
        case id, number, state
        case startedAt = "started_at"
        case finishedAt = "finished_at"
    }
}
