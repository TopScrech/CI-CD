import ScrechKit
import AppStoreConnect_Swift_SDK

struct WorkflowCard: View {
    @Environment(AppVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
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
                ForEach(actions) {
                    WorkflowActionCard($0)
                }
            }
        }
        .contextMenu {
#if DEBUG
            Section {
                Button {
                    Pasteboard.copy(workflow.id)
                } label: {
                    Text("Copy workflow id")
                    
                    Text(workflow.id)
                    
                    Image(systemName: "doc.on.doc")
                }
            }
#endif
            Button("Start build", systemImage: "play", action: startBuild)
            Button("Start clean build", systemImage: "play", action: startCleanBuild)
        }
    }
    
    private func startBuild() {
        if store.demoMode {
            if let build = vm.builds.first {
                vm.builds.append(build)
            }
        } else {
            Task {
                try await vm.startBuild(workflow.id)
            }
        }
    }
    
    private func startCleanBuild() {
        if store.demoMode {
            if let build = vm.builds.first {
                vm.builds.append(build)
            }
        } else {
            Task {
                try await vm.startBuild(workflow.id, clean: true)
            }
        }
    }
}

#Preview {
    List {
        WorkflowCard(CiWorkflow.preview)
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
