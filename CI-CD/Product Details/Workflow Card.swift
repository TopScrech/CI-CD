import SwiftUI
import AppStoreConnect_Swift_SDK

struct WorkflowCard: View {
    @Environment(ProductVM.self) private var vm
    
    private let workflow: CiWorkflow
    
    init(_ workflow: CiWorkflow) {
        self.workflow = workflow
    }
    
    var body: some View {
        Label(workflow.attributes?.name ?? "", systemImage: "server.rack")
            .contextMenu {
                Button {
                    Task {
                        try await vm.startBuild(workflow.id)
                    }
                } label: {
                    Label("Start build", systemImage: "play")
                }
            }
    }
}

//#Preview {
//    WorkflowCard()
//}
