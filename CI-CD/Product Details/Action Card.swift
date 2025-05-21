import SwiftUI
import AppStoreConnect_Swift_SDK

struct ActionCard: View {
    @State private var vm = ActionVM()
    
    private let action: CiBuildAction
    
    init(_ action: CiBuildAction) {
        self.action = action
    }
    
    var body: some View {
        NavigationLink {
            ActionDetails()
                .environment(vm)
        } label: {
            VStack(alignment: .leading, spacing: 5) {
                Text(action.attributes?.name ?? "-")
                    .semibold()
                    .padding(.bottom, 2)
                
                if vm.artifacts.count > 0 {
                    Text("📁 \(vm.artifacts.count)x Artifacts")
                }
                
                if let errors = vm.errorCount, errors > 0 {
                    Text("⛔️ \(errors)x Errors")
                }
                
                if let warnings = vm.warningCount, warnings > 0 {
                    Text("⚠️ \(warnings)x Warnings")
                }
                
                if let analyzerWarnings = vm.analyzerWarningCount, analyzerWarnings > 0 {
                    Text("⚠️ \(analyzerWarnings)x Analyzer Warnings")
                }
                
                if let testFailures = vm.testFailureCount, testFailures > 0 {
                    Text("⛔️ \(testFailures)x Test Failures")
                }
            }
            .animation(.default, value: vm.errorCount)
            .animation(.default, value: vm.warningCount)
            .animation(.default, value: vm.analyzerWarningCount)
            .animation(.default, value: vm.testFailureCount)
        }
        .task {
            async let issues: () = vm.buildIssues(action.id)
            async let artifacts: () = vm.buildArtifacts(action.id)
            
            _ = try? await (issues, artifacts)
        }
        .contextMenu {
            Button {
                UIPasteboard.general.string = action.id
            } label: {
                Text("Copy action id")
                
                Text(action.id)
                
                Image(systemName: "hammer")
            }
        }
    }
}

//#Preview {
//    ActionCard()
//}
