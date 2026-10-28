import Foundation
import Testing

@MainActor
struct ConnectWebRecoveryTests {
    @Test func retriedAfterRecovery() async throws {
        var requests = 0
        var recoveries = 0
        let result = try await ConnectWebRecovery.data {
            requests += 1
            if requests == 1 { throw ConnectWebError.signInRequired }
            return Data([1])
        } recover: {
            recoveries += 1
        }
        #expect(result == Data([1]))
        #expect(requests == 2)
        #expect(recoveries == 1)
    }

    @Test func stoppedAfterOneRecovery() async throws {
        var requests = 0
        var recoveries = 0
        do {
            _ = try await ConnectWebRecovery.data {
                requests += 1
                throw ConnectWebError.signInRequired
            } recover: {
                recoveries += 1
            }
            Issue.record("Expected sign-in error")
        } catch ConnectWebError.signInRequired {}
        #expect(requests == 2)
        #expect(recoveries == 1)
    }

    @Test(arguments: [ConnectWebError.accessDenied, .httpStatus(429), .wrongTeam])
    func didNotRecoverOtherFailures(error: ConnectWebError) async throws {
        var requests = 0
        var recoveries = 0
        do {
            _ = try await ConnectWebRecovery.data {
                requests += 1
                throw error
            } recover: {
                recoveries += 1
            }
            Issue.record("Expected request failure")
        } catch let failure as ConnectWebError {
            #expect(failure.errorDescription == error.errorDescription)
        }
        #expect(requests == 1)
        #expect(recoveries == 0)
    }

    @Test func didNotRetryWhenRecoveryFailed() async throws {
        var requests = 0
        do {
            _ = try await ConnectWebRecovery.data {
                requests += 1
                throw ConnectWebError.signInRequired
            } recover: {
                throw ConnectWebError.wrongTeam
            }
            Issue.record("Expected team mismatch")
        } catch ConnectWebError.wrongTeam {}
        #expect(requests == 1)
    }

    @Test func didNotRecoverCancelledRequest() async throws {
        var recoveries = 0
        do {
            _ = try await ConnectWebRecovery.data {
                throw CancellationError()
            } recover: {
                recoveries += 1
            }
            Issue.record("Expected cancellation")
        } catch is CancellationError {}
        #expect(recoveries == 0)
    }

    @Test func offeredSignInAfterUnexpectedRecoveryFailure() async throws {
        var requests = 0
        do {
            _ = try await ConnectWebRecovery.data {
                requests += 1
                throw ConnectWebError.signInRequired
            } recover: {
                throw NSError(domain: "WKErrorDomain", code: 4)
            }
            Issue.record("Expected recovery failure")
        } catch ConnectWebError.recoveryFailed {
            #expect(ConnectWebError.recoveryFailed.requiresSignIn)
        }
        #expect(requests == 1)
    }

    @Test func preservedPermissionFailureDuringRecovery() async throws {
        do {
            _ = try await ConnectWebRecovery.data {
                throw ConnectWebError.signInRequired
            } recover: {
                throw ConnectWebError.accessDenied
            }
            Issue.record("Expected permission error")
        } catch ConnectWebError.accessDenied {
            #expect(!ConnectWebError.accessDenied.requiresSignIn)
        }
    }

    @Test func preservedCancellationDuringRecovery() async throws {
        do {
            _ = try await ConnectWebRecovery.data {
                throw ConnectWebError.signInRequired
            } recover: {
                throw CancellationError()
            }
            Issue.record("Expected cancellation")
        } catch is CancellationError {}
    }
}
