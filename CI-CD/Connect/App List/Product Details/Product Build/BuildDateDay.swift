import Foundation

enum BuildDateDay {
    case today, yesterday, other

    init(date: Date, now: Date, calendar: Calendar) {
        if calendar.isDate(date, inSameDayAs: now) {
            self = .today
        } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
                  calendar.isDate(date, inSameDayAs: yesterday) {
            self = .yesterday
        } else {
            self = .other
        }
    }
}
