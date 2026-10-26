import SwiftUI
import AppStoreConnect_Swift_SDK

enum AppBuildStatus {
    case pending, pendingBetaReview, inBetaReview, betaRejected, running, succeeded, failed, errored, canceled, skipped, unknown

    init(_ build: CiBuildRun, betaStates: [ExternalBetaState] = []) {
        let completion = build.attributes?.completionStatus
        if completion != .failed && completion != .errored && completion != .canceled && completion != .skipped {
            if betaStates.contains(.betaRejected) {
                self = .betaRejected
                return
            }
            if betaStates.contains(.waitingForBetaReview) {
                self = .pendingBetaReview
                return
            }
            if betaStates.contains(.inBetaReview) {
                self = .inBetaReview
                return
            }
        }
        switch build.attributes?.executionProgress {
        case .pending: self = .pending
        case .running: self = .running
        default:
            switch build.attributes?.completionStatus {
            case .succeeded: self = .succeeded
            case .failed: self = .failed
            case .errored: self = .errored
            case .canceled: self = .canceled
            case .skipped: self = .skipped
            case nil: self = .unknown
            }
        }
    }

    func title(number: Int) -> LocalizedStringKey {
        switch self {
        case .pendingBetaReview: "Build \(number) pending beta review"
        case .inBetaReview: "Build \(number) in beta review"
        case .betaRejected: "Build \(number) rejected in beta review"
        case .pending: "Build \(number) pending"
        case .running: "Build \(number) running"
        case .succeeded: "Build \(number) succeeded"
        case .failed: "Build \(number) failed"
        case .errored: "Build \(number) errored"
        case .canceled: "Build \(number) canceled"
        case .skipped: "Build \(number) skipped"
        case .unknown: "Build \(number)"
        }
    }

    var symbol: String {
        switch self {
        case .pending, .pendingBetaReview, .inBetaReview: "clock"
        case .running: "arrow.trianglehead.2.clockwise.rotate.90"
        case .succeeded: "checkmark.circle"
        case .failed, .errored, .betaRejected: "xmark.circle"
        case .canceled: "minus.circle"
        case .skipped: "arrow.right.circle"
        case .unknown: "questionmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .pending, .pendingBetaReview, .inBetaReview: .orange
        case .running: .blue
        case .succeeded: .green
        case .failed, .errored, .betaRejected: .red
        case .canceled, .skipped, .unknown: .secondary
        }
    }
}
