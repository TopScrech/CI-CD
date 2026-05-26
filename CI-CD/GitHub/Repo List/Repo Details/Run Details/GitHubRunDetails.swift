import SwiftUI

struct GitHubRunDetails: View {
    @State private var vm = GitHubRunDetailsVM()
    @EnvironmentObject private var store: ValueStore
    
    private let run: GitHubWorkflowRun
    private let repository: GitHubRepository
    
    init(_ run: GitHubWorkflowRun, repository: GitHubRepository) {
        self.run = run
        self.repository = repository
    }
    
    var body: some View {
        TabView {
            Tab("Info", systemImage: "info.circle") {
                GitHubRunInfoList(run: run, jobs: vm.jobs, errorMessage: vm.errorMessage)
            }
            
            Tab("Artifacts", systemImage: "archivebox") {
                GitHubArtifactList(artifacts: vm.artifacts, errorMessage: vm.errorMessage)
            }
        }
        .navigationTitle(run.name ?? "Run")
        .refreshableTask {
            await refresh()
        }
        .toolbar {
            if let url = run.htmlURL {
                Link(destination: url) {
                    Image(systemName: "safari")
                }
            }
        }
    }
    
    private func refresh() async {
        await vm.fetch(run: run, repository: repository, store: store)
    }
}

#Preview {
    NavigationStack {
        GitHubRunDetails(GitHubPreview.workflowRun, repository: GitHubPreview.repository)
            .environmentObject(ValueStore())
    }
    .darkSchemePreferred()
}
