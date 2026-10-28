import Foundation
import Testing

@MainActor
struct ConnectWebSessionQueueTests {
    @Test func serializedRequestsForSameAccount() async throws {
        let accountID = UUID()
        var events: [String] = []
        var release: CheckedContinuation<Void, Never>?
        var first: Task<Void, Error>?
        await withCheckedContinuation { started in
            first = Task {
                try await ConnectWebSessionQueue.withAccess(accountID: accountID) {
                    events.append("first started")
                    await withCheckedContinuation {
                        release = $0
                        started.resume()
                    }
                    events.append("first finished")
                }
            }
        }
        var second: Task<Void, Error>?
        await withCheckedContinuation { attempted in
            second = Task {
                attempted.resume()
                try await ConnectWebSessionQueue.withAccess(accountID: accountID) {
                    events.append("second")
                }
            }
        }
        #expect(events == ["first started"])
        release?.resume()
        try await first?.value
        try await second?.value
        #expect(events == ["first started", "first finished", "second"])
    }

    @Test func releasedQueueAfterFailure() async throws {
        let accountID = UUID()
        do {
            try await ConnectWebSessionQueue.withAccess(accountID: accountID) {
                throw ConnectWebError.signInRequired
            }
            Issue.record("Expected failure")
        } catch ConnectWebError.signInRequired {}
        let value = try await ConnectWebSessionQueue.withAccess(accountID: accountID) { 1 }
        #expect(value == 1)
    }
}
