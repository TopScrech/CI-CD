import SwiftUI

struct GitHubRepoList: View {
    @State private var vm = GitHubRepoListVM()
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetAuth = false
    
    var body: some View {
        List {
            if store.githubDemoMode || store.githubAuthorized {
                if let errorMessage = vm.errorMessage {
                    ContentUnavailableView("GitHub error", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                }
                
                ForEach(vm.repositories) {
                    GitHubRepoRow($0)
                }
            } else {
                ProjectListCredentialsUnavailableView(serviceName: "GitHub") {
                    sheetAuth = true
                }
            }
        }
        .animation(.default, value: vm.repositories.count)
        .scrollIndicators(.hidden)
        .refreshable {
            refreshRepositories()
        }
        .task {
            refreshRepositories()
        }
        .onChange(of: store.githubAccount?.id) {
            refreshRepositories()
        }
        .onChange(of: store.githubDemoMode) {
            refreshRepositories()
        }
        .onChange(of: store.githubRefreshToken) {
            refreshRepositories()
        }
        .sheet($sheetAuth) {
            GitHubAuthView {
                refreshRepositories()
            }
        }
    }
    
    private func refreshRepositories() {
        Task {
            await vm.fetchRepositories(store: store)
        }
    }
}

#Preview {
    GitHubRepoList()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
