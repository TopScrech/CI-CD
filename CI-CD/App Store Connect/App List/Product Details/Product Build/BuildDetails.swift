import SwiftUI
import AppStoreConnect_Swift_SDK

struct BuildDetails: View {
    @Environment(BuildVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    private let build: CiBuildRun
    
    init(_ build: CiBuildRun) {
        self.build = build
    }
    
    var body: some View {
        List {
            Section {
                if !store.connectDemoMode, let workflow = build.relationships?.workflow?.data {
                    Button("Rebuild", systemImage: "hammer") {
                        Task {
                            try await vm.startRebuild(of: build.id, in: workflow.id, store: store)
                        }
                    }
                    
                    Button("Rebuild clean", systemImage: "hammer") {
                        Task {
                            try await vm.startRebuild(of: build.id, in: workflow.id, clean: true, store: store)
                        }
                    }
                }
            }
            
            BuildDetailsProgress(build)
            
            Section {
                if let startedReason = build.attributes?.startReason {
                    LabeledContent("Reason", value: startedReason.rawValue.lowercased().capitalized)
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
                    ForEach(vm.actions) {
                        ActionCard($0)
                    }
                }
            }
        }
        .navigationTitle("Build \(build.attributes?.number?.description ?? "")")
        .foregroundStyle(.foreground)
        .scrollIndicators(.never)
        .task {
            load()
        }
        .onChange(of: store.connectAccount?.id) {
            vm.reset()
            load()
        }
        .onChange(of: store.connectDemoMode) {
            vm.reset()
            load()
        }
        .onChange(of: store.connectRefreshToken) {
            vm.reset()
            load()
        }
    }

    private func load() {
        Task {
            guard !store.connectDemoMode else { return }

            try? await vm.buildActions(build.id, store: store)
        }
    }
}

#Preview {
    NavigationStack {
        BuildDetails(CiBuildRun.preview)
    }
    .darkSchemePreferred()
    .environment(BuildVM())
    .environmentObject(ValueStore())
}
