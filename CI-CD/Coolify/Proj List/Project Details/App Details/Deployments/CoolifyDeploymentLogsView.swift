import ScrechKit

struct CoolifyDeploymentLogsView: View {
    @EnvironmentObject private var store: ValueStore
    
    @State private var vm: CoolifyDeploymentLogsVM
    
    private let deployment: CoolifyDeployment
    
    init(_ deployment: CoolifyDeployment, account: CoolifyAccountSnapshot? = nil) {
        self.deployment = deployment
        _vm = State(initialValue: CoolifyDeploymentLogsVM(fallback: deployment, account: account))
    }
    
    var body: some View {
        ScrollView {
            if vm.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if vm.logLines.isEmpty {
                ContentUnavailableView("No logs available", systemImage: "doc.text.magnifyingglass")
            } else {
                LazyVStack(alignment: .leading) {
                    ForEach(vm.logLines) { line in
                        HStack(alignment: .top) {
                            Text(line.timeText ?? "--:--")
                                .secondary()
                                .frame(width: 44, alignment: .leading)
                            
                            Text(line.message)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .footnote(design: .monospaced)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
            }
        }
        .navigationTitle("Deployment logs")
        .navSubtitle(deployment.uuid ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: store.coolifyRefreshToken) {
            await load()
        }
        .onChange(of: store.coolifyAccount) {
            store.bumpRefreshToken(for: .coolify)
        }
    }

    private func load() async {
        guard let uuid = deployment.uuid else {
            vm.deployment = deployment
            vm.isLoading = false
            return
        }
        
        await vm.fetchDeployment(uuid, fallback: deployment, store: store)
    }
}

#Preview {
    NavigationStack {
        CoolifyDeploymentLogsView(Preview.coolifyDeployments[0])
    }
    .environmentObject(ValueStore())
}
