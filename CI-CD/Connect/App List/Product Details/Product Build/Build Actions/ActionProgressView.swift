import SwiftUI
import AppStoreConnect_Swift_SDK

struct ActionProgressView: View {
    private let action: CiBuildAction

    init(_ action: CiBuildAction) {
        self.action = action
    }

    var body: some View {
        HStack(spacing: 4) {
            if let status = action.attributes?.completionStatus {
                switch status {
                case .succeeded:
                    Label("Succeeded", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    
                case .failed:
                    Label("Failed", systemImage: "xmark.circle.fill")
                        .foregroundStyle(.red)
                    
                case .errored:
                    Label("Errored", systemImage: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)
                    
                case .canceled:
                    Label("Canceled", systemImage: "stop.circle")
                        .foregroundStyle(.secondary)
                    
                case .skipped:
                    Label("Skipped", systemImage: "forward.end.circle")
                        .foregroundStyle(.secondary)
                }
            } else if let progress = action.attributes?.executionProgress {
                switch progress {
                case .pending:
                    Label("Pending", systemImage: "clock")
                        .foregroundStyle(.secondary)
                    
                case .running:
                    ProgressView()
                        .controlSize(.small)

                    Text("Running")
                        .foregroundStyle(.orange)
                    
                case .complete:
                    Label("Complete", systemImage: "checkmark.circle")
                        .foregroundStyle(.secondary)
                }
            } else {
                Label("Status unavailable", systemImage: "questionmark.circle")
                    .foregroundStyle(.secondary)
            }
        }
        .labelStyle(CompactStatusLabelStyle())
        .font(.subheadline)
    }
}
