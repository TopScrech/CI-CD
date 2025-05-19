import SwiftUI
import AppStoreConnect_Swift_SDK

struct WorkflowCard: View {
    @Environment(ProductVM.self) private var vm
    
    private let workflow: CiWorkflow
    
    init(_ workflow: CiWorkflow) {
        self.workflow = workflow
    }
    
    var body: some View {
        Menu {
            Button {
                Task {
                    try await vm.startBuild(workflow.id)
                }
            } label: {
                Label("Start build", systemImage: "play")
            }
        } label: {
            Label(workflow.attributes?.name ?? "", systemImage: "server.rack")
                .foregroundStyle(.foreground)
        }
    }
}

//#Preview {
//    WorkflowCard()
//}
