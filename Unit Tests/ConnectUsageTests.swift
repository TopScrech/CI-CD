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

    @Test func handledEmptyQuota() {
        let plan = ConnectUsagePlan(used: 0, total: 0)
        #expect(plan.fractionUsed == 0)
        #expect(plan.totalHours == 0)
    }
}
