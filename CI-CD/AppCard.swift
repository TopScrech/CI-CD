import ScrechKit
import AppStoreConnect_Swift_SDK

struct AppCard: View {
    @State private var vm = AppVM()
    @EnvironmentObject private var store: ValueStore
    
    private let product: CiProduct
    
    init(_ product: CiProduct) {
        self.product = product
    }
    
    @State private var sheetVersions = false
    
    var body: some View {
        NavigationLink {
            ProductDetails(product)
        } label: {
            HStack {
                AppCardImage(product)
                
                VStack(alignment: .leading) {
                    if let attributes = product.attributes, let name = attributes.name {
                        Text(name)
                            .title3()
                    }
#if DEBUG
                    if let bundleId = product.relationships?.bundleID?.data?.id {
                        Text(bundleId)
                            .secondary()
                            .footnote()
                    }
#endif
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(vm.workflows) { workflow in
                        Text(workflow.attributes?.name ?? "")
                            .secondary()
                            .footnote()
                    }
                }
            }
        }
        .appCardContextMenu($sheetVersions, product: product)
        .environment(vm)
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
        .task {
            if store.demoMode {
                vm.workflows = [CiWorkflow.preview]
            } else {
                async let workflows: () = vm.fetchWorkflows(product.id)
                async let builds: () = vm.fetchBuilds(product.id)
                async let primaryRepos: () = vm.primaryRepositories(product.id)
                async let additionalRepos: () = vm.additionalRepositories(product.id)
                async let versions: () = vm.getVersions(product.relationships?.app?.data?.id)
                
                _ = try? await (workflows, builds, additionalRepos, primaryRepos, versions)
            }
        }
    }
}

#Preview {
    AppCard(CiProduct.preview)
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
