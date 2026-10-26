import SwiftUI
import AppStoreConnect_Swift_SDK

enum AppBuildStatus {
    case pending, running, succeeded, failed, errored, canceled, skipped, unknown

    init(_ build: CiBuildRun) {
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
        case .pending: "clock"
        case .running: "arrow.trianglehead.2.clockwise.rotate.90"
        case .succeeded: "checkmark.circle"
        case .failed, .errored: "xmark.circle"
        case .canceled: "minus.circle"
        case .skipped: "arrow.right.circle"
        case .unknown: "questionmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .pending: .orange
        case .running: .blue
        case .succeeded: .green
        case .failed, .errored: .red
        case .canceled, .skipped, .unknown: .secondary
        }
    }
}
