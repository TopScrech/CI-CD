import Foundation

@MainActor
enum ConnectWebRecovery {
    static func data(request: @MainActor () async throws -> Data, recover: @MainActor () async throws -> Void) async throws -> Data {
        try Task.checkCancellation()
        do {
            return try await request()
        } catch ConnectWebError.signInRequired {
            try Task.checkCancellation()
            do {
                try await recover()
            } catch is CancellationError {
                throw CancellationError()
            } catch let error as ConnectWebError {
                throw error
            } catch {
                try Task.checkCancellation()
                throw ConnectWebError.recoveryFailed
            }
            try Task.checkCancellation()
            return try await request()
        }
    }
}
