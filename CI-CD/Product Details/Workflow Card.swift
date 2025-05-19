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
            VStack(alignment: .leading) {
                Label {
                    Text(workflow.attributes?.name ?? "")
                } icon: {
                    Image(systemName: "server.rack")
                        .bold()
                        .foregroundStyle(iconColor)
                }
                .foregroundStyle(.foreground)
                
                //                if let actions = workflow.attributes?.actions {
                //                    Divider()
                //
                //                    ForEach(actions) { action in
                //                        Text(action.name ?? "-")
                //
                //                        Text(action.platform?.rawValue ?? "-")
                //                    }
                //                }
            }
        }
        .contextMenu {
            Label("Start build", systemImage: "play")
        }
    }
}

extension CiAction: @retroactive Identifiable {
    public var id: UUID {
        UUID()
    }
}

#Preview {
    List {
        WorkflowCard(CiWorkflow.preview)
    }
    .environment(ProductVM())
}
