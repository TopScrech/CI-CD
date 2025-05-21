import ScrechKit
import AppStoreConnect_Swift_SDK

struct BuildDetails: View {
    @Environment(BuildVM.self) private var vm
    
    private let build: CiBuildRun
    
    init(_ build: CiBuildRun) {
        self.build = build
    }
    
    var body: some View {        
        List {
            Section {
                if let workflow = build.relationships?.workflow?.data {
                    Button {
                        Task {
                            try await vm.startRebuild(of: build.id, in: workflow.id)
                        }
                    } label: {
                        Label("Rebuild", systemImage: "hammer")
                    }
                    
                    Button {
                        Task {
                            try await vm.startRebuild(of: build.id, in: workflow.id, clean: true)
                        }
                    } label: {
                        Label("Rebuild clean", systemImage: "hammer")
                    }
                }
            }
            
            BuildDetailsProgress(build)
            
            Section {
                if let startedReason = build.attributes?.startReason {
                    ListParam("Reason", param: startedReason.rawValue.lowercased().capitalized)
                }
                
                if let created = build.attributes?.createdDate {
                    HStack {
                        Text("Created")
                        
                        Spacer()
                        
                        Text(created, format: .dateTime)
                            .secondary()
                    }
                }
                
                if let started = build.attributes?.startedDate {
                    HStack {
                        Text("Started")
                        
                        Spacer()
                        
                        Text(started, format: .dateTime)
                            .secondary()
                    }
                }
                
                if let finished = build.attributes?.finishedDate {
                    HStack {
                        Text("Finished")
                        
                        Spacer()
                        
                        Text(finished, format: .dateTime)
                            .secondary()
                    }
                }
            }
            
            BuildCommitDetails(build)
            
            if !vm.actions.isEmpty {
                Section("Build actions") {
                    ForEach(vm.actions) { action in
                        ActionCard(action)
                    }
                }
            }
        }
        .navigationTitle("Build \(build.attributes?.number?.description ?? "")")
        .foregroundStyle(.foreground)
        .scrollIndicators(.never)
        .task {
            try? await vm.buildActions(build.id)
        }
    }
}

#Preview {
    BuildDetails(CiBuildRun.preview)
        .environment(BuildVM())
        .darkSchemePreferred()
}
