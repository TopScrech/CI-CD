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
    let commitMessage: String?
    let logs: String?
    
    var createdDate: Date? {
        Self.parseDate(createdAt)
    }
    
    var updatedDate: Date? {
        Self.parseDate(updatedAt)
    }
    
    var finishedDate: Date? {
        guard status == .finished else {
            return nil
        }
        
        return updatedDate
    }
    
    var createdAtText: String? {
        guard let createdDate else {
            return nil
        }
        
        return createdDate.formatted(.dateTime)
    }
    
    var finishedDateText: String? {
        guard let finishedDate else {
            return nil
        }
        
        return finishedDate.formatted(.dateTime)
    }
    
    var finishedAgoText: String? {
        guard let finishedDate else {
            return nil
        }
        
        return Self.relativeFormatter.localizedString(for: finishedDate, relativeTo: .now)
    }
    
    var durationText: String? {
        guard let createdDate, let finishedDate, finishedDate >= createdDate else {
            return nil
        }
        
        return Self.durationText(from: finishedDate.timeIntervalSince(createdDate))
    }
    
    private static let dateParsers = [
        ISO8601DateFormatter.internetDateTime,
        ISO8601DateFormatter.internetDateTimeFractionalSeconds
    ]
    
    private static let relativeFormatter = RelativeDateTimeFormatter()
    
    private static func parseDate(_ value: String?) -> Date? {
        guard let value, !value.isEmpty else {
            return nil
        }
        
        return dateParsers.lazy.compactMap { $0.date(from: value) }.first
    }
    
    private static func durationText(from interval: TimeInterval) -> String {
        let totalSeconds = Int(interval.rounded())
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        
        return "\(seconds)s"
    }
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

private extension ISO8601DateFormatter {
    static let internetDateTime: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    static let internetDateTimeFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
