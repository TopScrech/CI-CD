import SwiftUI

struct BuildDateView: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.timeZone) private var timeZone

    let date: Date

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let day = BuildDateDay(date: date, now: context.date, calendar: calendarInCurrentTimeZone)

            switch day {
            case .today:
                Text("Today, \(date, format: .dateTime.hour().minute())")
            case .yesterday:
                Text("Yesterday, \(date, format: .dateTime.hour().minute())")
            case .other:
                Text(date, format: .dateTime)
            }
        }
    }

    private var calendarInCurrentTimeZone: Calendar {
        var calendar = calendar
        calendar.timeZone = timeZone
        return calendar
    }
}
