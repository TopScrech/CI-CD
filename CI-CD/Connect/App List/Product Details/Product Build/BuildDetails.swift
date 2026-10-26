import ScrechKit
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
            BuildDetailsProgress(build)
            
            Section {
                if let startedReason = build.attributes?.startReason {
                    LabeledContent("Reason", value: startedReason.rawValue.lowercased().capitalized)
                }
                
                if let created = build.attributes?.createdDate {
                    HStack {
                        Text("Created")
                        
                        Spacer()
                        
                        BuildDateView(date: created)
                            .secondary()
                    }
                }
                
                if let started = build.attributes?.startedDate {
                    HStack {
                        Text("Started")
                        
                        Spacer()
                        
                        BuildDateView(date: started)
                            .secondary()
                    }
                }
                
                if let finished = build.attributes?.finishedDate {
                    HStack {
                        Text("Finished")
                        
                        Spacer()
                        
                        BuildDateView(date: finished)
                            .secondary()
                    }
                }
            }
            
            Section {
                BuildTimingView(build: build)
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
        .toolbar {
            BuildDetailsToolbar(build: build)
        }
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
