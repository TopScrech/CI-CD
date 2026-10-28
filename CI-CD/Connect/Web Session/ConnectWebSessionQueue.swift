import Foundation

@MainActor
enum ConnectWebSessionQueue {
    private static var waiters: [UUID: [CheckedContinuation<Void, Never>]] = [:]

    static func withAccess<T>(accountID: UUID, operation: @MainActor () async throws -> T) async throws -> T {
        await acquire(accountID: accountID)
        defer { release(accountID: accountID) }
        try Task.checkCancellation()
        return try await operation()
    }

    private static func acquire(accountID: UUID) async {
        guard waiters[accountID] != nil else {
            waiters[accountID] = []
            return
        }
        await withCheckedContinuation { waiters[accountID, default: []].append($0) }
    }

    private static func release(accountID: UUID) {
        guard var pending = waiters[accountID], !pending.isEmpty else {
            waiters.removeValue(forKey: accountID)
            return
        }
        let next = pending.removeFirst()
        waiters[accountID] = pending
        next.resume()
    }
}
