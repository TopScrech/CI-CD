import Foundation

struct ConnectUsagePlan: Codable {
    let used: Double
    let total: Double
    var resetDate: String?
    var resetDateTime: String?

    enum CodingKeys: String, CodingKey {
        case used, total,
             resetDate = "reset_date",
             resetDateTime = "reset_date_time"
    }

    var resetOn: Date? {
        if let resetDateTime {
            if let date = try? Date(resetDateTime, strategy: .iso8601) { return date }
            if let date = try? Date(resetDateTime, strategy: .iso8601.year().month().day().time(includingFractionalSeconds: true).timeZone(separator: .colon)) { return date }
        }

        guard let resetDate else { return nil }
        return try? Date(resetDate, strategy: Date.ParseStrategy(
            format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)",
            locale: Locale(identifier: "en_US_POSIX"),
            timeZone: .current
        ))
    }

    var totalHours: Double { max(0, total) / 60 }
    var fractionUsed: Double { total > 0 ? max(0, used) / total : 0 }
    var progress: Double { min(1, fractionUsed) }
}
