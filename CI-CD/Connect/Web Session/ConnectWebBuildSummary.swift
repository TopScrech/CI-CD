import Foundation

struct ConnectWebBuildSummary: Codable, Equatable {
    let build: ConnectWebBuildTiming
    let xcode: String?
    let macOS: String?
    let totalUsageTime: TimeInterval?

    var duration: TimeInterval? {
        guard let start = build.startedAt, let finish = build.finishedAt else { return nil }
        let interval = finish.timeIntervalSince(start)
        return interval >= 0 ? interval : nil
    }

    var usage: TimeInterval? {
        guard build.isComplete, let totalUsageTime, totalUsageTime.isFinite, totalUsageTime >= 0 else { return nil }
        return totalUsageTime
    }

    enum CodingKeys: String, CodingKey {
        case build
        case xcode = "builder_name"
        case macOS = "os_name"
        case totalUsageTime = "total_usage_time"
    }

    static func decode(_ data: Data) throws -> Self {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let value = try decoder.singleValueContainer().decode(String.self)
            if let date = try? Date(value, strategy: .iso8601.year().month().day().time(includingFractionalSeconds: true).timeZone(separator: .colon)) { return date }
            return try Date(value, strategy: .iso8601)
        }
        return try decoder.decode(Self.self, from: data)
    }
}
