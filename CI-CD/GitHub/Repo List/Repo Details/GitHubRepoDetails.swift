import ScrechKit

struct GitHubRepoDetails: View {
    @State private var vm = GitHubRepoDetailsVM()
    @EnvironmentObject private var store: ValueStore
    
    private let repository: GitHubRepository
    
    init(_ repository: GitHubRepository) {
        self.repository = repository
    }
    
    var body: some View {
        List {
            if let errorMessage = vm.errorMessage {
                ContentUnavailableView("GitHub error", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
            }
            
            Section("Workflows") {
                if vm.workflows.isEmpty {
                    ContentUnavailableView("No workflows", systemImage: "gearshape.2")
                } else {
                    ForEach(vm.workflows) {
                        GitHubWorkflowRow($0) { workflow in
                            Task {
                                await vm.dispatch(workflow, repository: repository, store: store)
                            }
                        }
                    }
                }
            }
            
            Section("Runs") {
                if vm.runs.isEmpty {
                    ContentUnavailableView("No runs", systemImage: "clock")
                } else {
                    ForEach(vm.runs) { run in
                        GitHubWorkflowRunRow(run) {
                            Task {
                                await vm.rerun(run, repository: repository, store: store)
                            }
                        } cancel: {
                            Task {
                                await vm.cancel(run, repository: repository, store: store)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(repository.name)
        .animation(.default, value: vm.runs)
        .refreshableTask {
            await refresh()
        }
        .onChange(of: store.githubRefreshToken) {
            Task {
                await refresh()
            }
        }
        .toolbar {
            if let url = repository.htmlURL {
                Link(destination: url) {
                    Image(systemName: "safari")
                }
            }
        }
    }
    
    private func refresh() async {
        await vm.fetch(repository: repository, store: store)
    }
}

#Preview {
    NavigationStack {
        GitHubRepoDetails(GitHubPreview.repository)
            .environmentObject(ValueStore())
    }
    .darkSchemePreferred()
}
