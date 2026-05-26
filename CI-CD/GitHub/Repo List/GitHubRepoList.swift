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
            await refreshRepositories()
        }
        .task {
            await refreshRepositories()
        }
        .onChange(of: store.githubAccount?.id) {
            Task {
                await refreshRepositories()
            }
        }
        .onChange(of: store.githubDemoMode) {
            Task {
                await refreshRepositories()
            }
        }
        .onChange(of: store.githubRefreshToken) {
            Task {
                await refreshRepositories()
            }
        }
        .sheet($sheetAuth) {
            GitHubAuthView {
                await refreshRepositories()
            }
        }
    }
    
    private func refreshRepositories() async {
        await vm.fetchRepositories(store: store)
    }
}

#Preview {
    GitHubRepoList()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
