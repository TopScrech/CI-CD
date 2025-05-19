import SwiftUI
import AppStoreConnect_Swift_SDK

struct WorkflowCard: View {
    @Environment(ProductVM.self) private var vm
    
    private let workflow: CiWorkflow
    
    init(_ workflow: CiWorkflow) {
        self.workflow = workflow
    }
    
    private var iconColor: Color {
        if let isEnabled = workflow.attributes?.isEnabled {
            isEnabled ? .green : .red
        } else {
            .gray
        }
    }
    
    var body: some View {
        Button {
            Task {
                try await vm.startBuild(workflow.id)
            }
        } label: {
            Label {
                Text(workflow.attributes?.name ?? "")
            } icon: {
                Image(systemName: "server.rack")
                    .bold()
                    .foregroundStyle(iconColor)
            }
            .foregroundStyle(.foreground)
        }
        .contextMenu {
            Label("Start build", systemImage: "play")
        }
    }
}

#Preview {
    List {
        WorkflowCard(CiWorkflow.preview)
    }
    .environment(ProductVM())
}
