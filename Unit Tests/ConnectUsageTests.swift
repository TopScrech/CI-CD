import Foundation
import Testing

struct ConnectUsageTests {
    @Test func decodedQuotaInMinutes() throws {
        let data = Data(#"{"plan":{"name":"25 hours","used":120,"available":1380,"total":1500}}"#.utf8)
        let plan = try JSONDecoder().decode(ConnectUsageSummary.self, from: data).plan
        #expect(plan.totalHours == 25)
        #expect(plan.fractionUsed == 0.08)
        #expect(plan.progress == 0.08)
    }

    @Test func clampedProgressWithoutHidingOverage() {
        let plan = ConnectUsagePlan(used: 1800, total: 1500)
        #expect(plan.fractionUsed == 1.2)
        #expect(plan.progress == 1)
    }

    @Test func decodedResetDate() throws {
        let data = Data(#"{"plan":{"used":120,"total":1500,"reset_date":"2026-11-16","reset_date_time":"2026-11-16T09:43:54Z"}}"#.utf8)
        let plan = try JSONDecoder().decode(ConnectUsageSummary.self, from: data).plan
        #expect(plan.resetOn == (try Date("2026-11-16T09:43:54Z", strategy: .iso8601)))
        let cached = try JSONDecoder().decode(ConnectUsagePlan.self, from: JSONEncoder().encode(plan))
        #expect(cached.resetOn == plan.resetOn)
    }

    @Test func parsedDateOnlyReset() throws {
        let plan = ConnectUsagePlan(used: 0, total: 1500, resetDate: "2026-11-16")
        let date = try #require(plan.resetOn)
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        #expect(components.year == 2026)
        #expect(components.month == 11)
        #expect(components.day == 16)
        #expect(ConnectUsagePlan(used: 0, total: 1500).resetOn == nil)
    }

    @Test func handledEmptyQuota() {
        let plan = ConnectUsagePlan(used: 0, total: 0)
        #expect(plan.fractionUsed == 0)
        #expect(plan.totalHours == 0)
    }
}
