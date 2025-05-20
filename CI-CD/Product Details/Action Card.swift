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
            IssueList()
                .environment(vm)
        } label: {
            VStack(alignment: .leading) {
                Text(action.attributes?.name ?? "-")
                
                if let errors = vm.errorCount, errors > 0 {
                    HStack {
                        Text("⛔️ Errors")
                        
                        Spacer()
                        
                        Text(errors)
                    }
                }
                
                if let warnings = vm.warningCount, warnings > 0 {
                    HStack {
                        Text("⚠️ Warnings")
                        
                        Spacer()
                        
                        Text(warnings)
                    }
                }
                
                if let analyzerWarnings = vm.analyzerWarningCount, analyzerWarnings > 0 {
                    HStack {
                        Text("⚠️ Analyzer Warnings")
                        
                        Spacer()
                        
                        Text(analyzerWarnings)
                    }
                }
                
                if let testFailures = vm.testFailureCount, testFailures > 0 {
                    HStack {
                        Text("⛔️ Test Failures")
                        
                        Spacer()
                        
                        Text(testFailures)
                    }
                }
            }
            .animation(.default, value: vm.errorCount)
            .animation(.default, value: vm.warningCount)
            .animation(.default, value: vm.analyzerWarningCount)
            .animation(.default, value: vm.testFailureCount)
        }
        .task {
            try? await vm.buildIssues(action.id)
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

@Observable
final class ActionVM {
    var issues: [CiIssue] = []
    
    var warningCount: Int? {
        issues.filter {
            $0.attributes?.issueType == .warning
        }.count
    }
    
    var errorCount: Int? {
        issues.filter {
            $0.attributes?.issueType == .error
        }.count
    }
    
    var analyzerWarningCount: Int? {
        issues.filter {
            $0.attributes?.issueType == .analyzerWarning
        }.count
    }
    
    var testFailureCount: Int? {
        issues.filter {
            $0.attributes?.issueType == .testFailure
        }.count
    }
    
    func buildIssues(_ actionId: String) async throws {
        guard let provider = try await provider() else {
            return
        }
        
        let request = APIEndpoint
            .v1
            .ciBuildActions
            .id(actionId)
            .issues
            .get()
        
        do {
            issues = try await provider.request(request).data
        } catch {
            print(error)
        }
    }
}

//#Preview {
//    ActionCard()
//}
