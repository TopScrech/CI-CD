import Foundation

struct ConnectUsagePlan: Codable {
    let used: Double
    let total: Double

    var totalHours: Double { max(0, total) / 60 }
    var fractionUsed: Double { total > 0 ? max(0, used) / total : 0 }
    var progress: Double { min(1, fractionUsed) }
}
