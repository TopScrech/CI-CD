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
            VStack(alignment: .leading) {
                Text(action.attributes?.name ?? "-")
                
                if vm.artifacts.count > 0 {
                    HStack {
                        Text("📁 Artifacts")
                        
                        Spacer()
                        
                        Text(vm.artifacts.count)
                    }
                }
                
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
            try? await vm.buildArtifacts(action.id)
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
