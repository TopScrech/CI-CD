import ScrechKit
import ASC

struct BuildDetails: View {
    @State private var webBuildVM = ConnectWebBuildVM()
    @Environment(BuildVM.self) private var vm
    @Environment(\.connectProductID) private var productID
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
                    LabeledContent("Start condition", value: startedReason.rawValue.lowercased().capitalized)
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
            
            if #available(iOS 26, macOS 26, visionOS 26, *) {
                ConnectWebBuildSectionView(build: build)
                    .id("\(store.connectAccount?.id.uuidString ?? "").\(store.connectDemoMode)")
            } else {
                Section {
                    BuildTimingView(build: build)
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
        .toolbar {
            BuildDetailsToolbar(build: build)
        }
        .environment(webBuildVM)
        .foregroundStyle(.foreground)
        .scrollIndicators(.never)
        .refreshableTask {
            guard !store.connectDemoMode else { return }

            try? await vm.buildActions(build.id, store: store)

            if #available(iOS 26, macOS 26, visionOS 26, *), let accountID = store.connectAccount?.id {
                await webBuildVM.load(accountID: accountID, productID: productID, buildID: build.id, buildNumber: build.attributes?.number)
            }
        }
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
