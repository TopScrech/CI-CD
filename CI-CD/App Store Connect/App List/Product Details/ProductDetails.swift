import SwiftUI
@preconcurrency import AppStoreConnect_Swift_SDK

struct ProductDetails: View {
    @Environment(AppVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    private let product: CiProduct
    
    init(_ product: CiProduct) {
        self.product = product
    }
    
    private var authors: [CiGitUser] {
        Array(Set(vm.builds.compactMap(\.attributes?.sourceCommit?.author)))
    }
    
    private var filteredBuilds: [CiBuildRun] {
        if let selectedAuthor {
            vm.builds.filter {
                $0.attributes?.sourceCommit?.author?.displayName == selectedAuthor.displayName
            }
        } else {
            vm.builds
        }
    }
    
    @State private var selectedAuthor: CiGitUser?
    
    var body: some View {
        List {
            if !vm.workflows.isEmpty {
                Section("Workflows") {
                    ForEach(vm.workflows) {
                        WorkflowCard($0)
                    }
                }
            }
            
            if vm.primaryRepos.count > 0 {
                Section("Primary repositories") {
                    ForEach(vm.primaryRepos) {
                        RepoCard($0)
                    }
                }
            }
            
            if vm.additionalRepos.count > 0 {
                Section("Additional repositories") {
                    ForEach(vm.additionalRepos) {
                        RepoCard($0)
                    }
                }
            }
            
            if vm.builds.isEmpty {
                ContentUnavailableView(
                    "No builds found",
                    systemImage: "exclamationmark.triangle",
                    description: Text("This could happen due to an error")
                )
            } else {
                Section {
                    ForEach(filteredBuilds.reversed()) {
                        BuildCard($0)
                    }
                }
            }
        }
        .animation(.default, value: selectedAuthor)
        .animation(.default, value: filteredBuilds.count)
        .navigationTitle(product.attributes?.name ?? "")
        .toolbar {
            Menu {
                Section {
                    Button {
                        selectedAuthor = nil
                    } label: {
                        Text("All")
                        
                        if selectedAuthor == nil {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                ForEach(authors, id: \.self) { author in
                    Button {
                        selectedAuthor = author
                    } label: {
                        Text(author.displayName ?? "Unknown Author")
                        
                        if selectedAuthor == author {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .symbolVariant(selectedAuthor == nil ? .none : .fill)
            }
        }
        .refreshableTask {
            await refresh()
        }
        .task {
            await refresh()
        }
        .onChange(of: store.connectAccount?.id) {
            Task {
                await refresh()
            }
        }
        .onChange(of: store.connectDemoMode) {
            Task {
                await refresh()
            }
        }
        .onChange(of: store.connectRefreshToken) {
            Task {
                await refresh()
            }
        }
    }

    private func refresh() async {
        vm.primaryRepos = []
        vm.additionalRepos = []

        if store.connectDemoMode {
            vm.builds = [CiBuildRun.preview]
            return
        }

        async let builds: () = vm.fetchBuilds(product.id, store: store)
        async let primary: () = vm.primaryRepositories(product.id, store: store)
        async let additional: () = vm.additionalRepositories(product.id, store: store)

        _ = try? await (builds, primary, additional)
    }
}

#Preview {
    NavigationStack {
        ProductDetails(CiProduct.preview)
    }
    .environmentObject(ValueStore())
    .environment(AppVM())
    .darkSchemePreferred()
}
