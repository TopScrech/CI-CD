import SwiftUI
import AppStoreConnect_Swift_SDK

struct BuildDetailsProgress: View {
    private let build: CiBuildRun
    
    init(_ build: CiBuildRun) {
        self.build = build
    }
    
    var body: some View {
        Section {
            if let executionProgress = build.attributes?.executionProgress {
                HStack {
                    let color: Color = switch executionProgress {
                    case .complete: .green
                    case .running: .orange
                    case .pending: .gray
                    }
                    
                    Capsule()
                        .frame(width: 5)
                        .frame(maxHeight: .infinity)
                        .foregroundStyle(color.gradient)
                        .padding(.vertical, 4)
                    
                    Text("Execution progress")
                    
                    Spacer()
                    
                    Text(executionProgress.rawValue.lowercased().capitalized)
                        .secondary()
                    
                    if executionProgress == .running {
                        ProgressView()
                    } else if executionProgress == .pending {
                        Image(systemName: "clock")
                    }
                }
            }
            
            if let completionStatus = build.attributes?.completionStatus {
                HStack {
                    let color: Color = switch completionStatus {
                    case .succeeded: .green
                    case .failed, .errored: .red
                    case .canceled, .skipped: .gray
                    }
                    
                    Capsule()
                        .frame(width: 5)
                        .frame(maxHeight: .infinity)
                        .foregroundStyle(color.gradient)
                        .padding(.vertical, 4)
                    
                    Text("Completion status")
                    
                    Spacer()
                    
                    Text(completionStatus.rawValue.lowercased().capitalized)
                        .secondary()
                }
            }
        }
    }
}

#Preview {
    List {
        BuildDetailsProgress(CiBuildRun.preview)
    }
    .darkSchemePreferred()
}
