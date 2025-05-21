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
        Menu {
#if DEBUG
            Section {
                Button {
                    UIPasteboard.general.string = workflow.id
                } label: {
                    Text("Copy workflow id")
                    
                    Text(workflow.id)
                    
                    Image(systemName: "doc.on.doc")
                }
            }
#endif
            Button {
                Task {
                    try await vm.startBuild(workflow.id)
                }
            } label: {
                Label("Start build", systemImage: "play")
            }
            
            Button {
                Task {
                    try await vm.startBuild(workflow.id, clean: true)
                }
            } label: {
                Label("Start clean build", systemImage: "play")
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Label {
                    Text(workflow.attributes?.name ?? "")
                    
                    if let description = workflow.attributes?.description, !description.isEmpty {
                        Text(description)
                            .secondary()
                            .footnote()
                    }
                } icon: {
                    Image(systemName: "server.rack")
                        .bold()
                        .foregroundStyle(iconColor)
                        .frame(width: 30)
                }
                .foregroundStyle(.foreground)
                
                if let actions = workflow.attributes?.actions {
                    ForEach(actions) { action in
                        WorkflowActionCard(action)
                    }
                }
            }
        }
        .foregroundStyle(.foreground)
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
