import ScrechKit
@preconcurrency import AppStoreConnect_Swift_SDK

struct AppCard: View {
    @Environment(AppVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    private let product: CiProduct
    
    init(_ product: CiProduct) {
        self.product = product
    }
    
    @State private var sheetVersions = false
    
    var body: some View {
        NavigationLink(value: ProductRoute(id: product.id)) {
            HStack {
                AppCardImage(product)
                
                VStack(alignment: .leading) {
                    if let attributes = product.attributes, let name = attributes.name {
                        Text(name)
                            .title3()
                    }

                    if let build = vm.latestBuild {
                        AppLatestBuildView(build: build, betaStates: vm.latestBuildBetaStates)
                    }
                }
                
                Spacer()
            }
        }
        .appCardContextMenu($sheetVersions, product: product)
        .environment(vm)
        .task {
            load()
        }
        .sheet($sheetVersions) {
            NavigationView {
                if let appId = product.relationships?.app?.data?.id {
                    AppVersions(appId, for: product.attributes?.name)
                        .environment(vm)
                } else {
                    Text("Error")
                }
            }
        }
        .onChange(of: store.connectAccount?.id, load)
        .onChange(of: store.connectDemoMode, load)
        .onChange(of: store.connectRefreshToken, load)
    }
    
    private func load() {
        vm.restoreLatestBuild(product.id, store: store)
        vm.restoreRepositories(product.id, store: store)

        Task {
            if store.connectDemoMode {
                vm.workflows = [CiWorkflow.preview]
                vm.builds = [CiBuildRun.preview]
            } else {
                async let workflows: () = vm.fetchWorkflows(product.id, store: store)
                async let builds: () = vm.fetchBuilds(product.id, store: store)
                async let primaryRepos: () = vm.primaryRepositories(product.id, store: store)
                async let additionalRepos: () = vm.additionalRepositories(product.id, store: store)
                async let versions: () = vm.getVersions(product.relationships?.app?.data?.id, store: store)
                
                _ = try? await (workflows, builds, additionalRepos, primaryRepos, versions)
            }
        }
    }
}

#Preview {
    AppCard(CiProduct.preview)
        .darkSchemePreferred()
        .environmentObject(ValueStore())
        .environment(AppVM())
}
