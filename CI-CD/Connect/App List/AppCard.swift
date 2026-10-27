import ScrechKit
import ASC

struct AppCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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
                            .transition(.opacity)
                    }
                }
                
                Spacer()
            }
        }
        .animation(reduceMotion ? nil : .easeInOut, value: vm.latestBuild?.id)
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
        let productID = product.id
        let appID = product.relationships?.app?.data?.id

        vm.restoreLatestBuild(productID, store: store)
        vm.restoreRepositories(productID, store: store)

        Task {
            if store.connectDemoMode {
                vm.workflows = [CiWorkflow.preview]
                vm.builds = [CiBuildRun.preview]
            } else {
                async let workflows: () = vm.fetchWorkflows(productID, store: store)
                async let builds: () = vm.fetchBuilds(productID, store: store)
                async let primaryRepos: () = vm.primaryRepositories(productID, store: store)
                async let additionalRepos: () = vm.additionalRepositories(productID, store: store)
                async let versions: () = vm.getVersions(appID, store: store)
                
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
