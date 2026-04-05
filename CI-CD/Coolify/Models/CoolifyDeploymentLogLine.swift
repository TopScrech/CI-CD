import Foundation

struct CoolifyDeploymentLogLine: Identifiable {
    let id = UUID()
    let timestamp: Date?
    let message: String
    
    var timeText: String? {
        guard let timestamp else {
            return nil
        }
        
        return timestamp.formatted(.dateTime.hour().minute())
    }
    
    init(_ rawLine: String) {
        let trimmedLine = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
        let parsedLine = Self.parse(trimmedLine)
        
        timestamp = parsedLine.timestamp
        message = parsedLine.message
    }
    
    init(timestamp: Date?, message: String) {
        self.timestamp = timestamp
        self.message = message.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private static func parse(_ line: String) -> (timestamp: Date?, message: String) {
        guard !line.isEmpty else {
            return (nil, "")
        }
        
        if let range = line.firstBracketRange {
            let candidate = String(line[range])
            if let date = parseDate(candidate) {
                let message = line.removingPrefixBracketRange(range)
                return (date, message)
            }
        }
        
        let parts = line.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
        
        if let first = parts.first, let date = parseDate(String(first)) {
            let message = line.dropFirst(first.count).trimmingCharacters(in: .whitespaces)
            return (date, message)
        }
        
        if parts.count >= 2 {
            let candidate = "\(parts[0]) \(parts[1])"
            if let date = parseDate(candidate) {
                let prefixLength = parts[0].count + parts[1].count + 1
                let message = line.dropFirst(prefixLength).trimmingCharacters(in: .whitespaces)
                return (date, message)
            }
        }
        
        return (nil, line)
    }
    
    static func parseDate(_ value: String) -> Date? {
        let trimmedValue = value.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
        
        return ISO8601DateFormatter.internetDateTime.date(from: trimmedValue)
            ?? ISO8601DateFormatter.internetDateTimeFractionalSeconds.date(from: trimmedValue)
            ?? DateFormatter.coolifyLogDateTime.date(from: trimmedValue)
            ?? DateFormatter.coolifyLogDateTimeFractionalSeconds.date(from: trimmedValue)
    }
}

private extension String {
    var firstBracketRange: ClosedRange<String.Index>? {
        guard first == "[", let endIndex = firstIndex(of: "]") else {
            return nil
        }
        
        return startIndex...endIndex
    }
    
    func removingPrefixBracketRange(_ range: ClosedRange<String.Index>) -> String {
        guard range.upperBound < index(before: endIndex) else {
            return ""
        }
        
        let nextIndex = index(after: range.upperBound)
        return self[nextIndex...].trimmingCharacters(in: .whitespaces)
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

private extension DateFormatter {
    static let coolifyLogDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    static let coolifyLogDateTimeFractionalSeconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
}
