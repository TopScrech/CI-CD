import Foundation

@MainActor
enum ConnectWebRecovery {
    static func data(request: @MainActor () async throws -> Data, recover: @MainActor () async throws -> Void) async throws -> Data {
        try Task.checkCancellation()
        do {
            return try await request()
        } catch ConnectWebError.signInRequired {
            try Task.checkCancellation()
            try await recover()
            try Task.checkCancellation()
            return try await request()
        }
    }
}
