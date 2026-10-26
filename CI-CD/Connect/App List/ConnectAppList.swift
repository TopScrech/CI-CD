import ScrechKit
import AppStoreConnect_Swift_SDK

struct ConnectAppList: View {
    @State private var vm = AppListVM()
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetAuth = false
    
    var body: some View {
        List {
            if store.connectDemoMode || store.connectAuthorized {
                ForEach(vm.visibleProducts(hidingRemovedApps: store.connectHideRemovedApps && !store.connectDemoMode)) {
                    AppCard($0)
                        .environment(vm.appViewModel(for: $0.id))
                }
            } else {
                ProjectListCredentialsUnavailableView(serviceName: "App Store Connect") {
                    sheetAuth = true
                }
            }
        }
        .navigationDestination(for: ProductRoute.self) { route in
            if let product = vm.products.first(where: { $0.id == route.id }) {
                ProductDetails(product)
                    .environment(vm.appViewModel(for: route.id))
            }
        }
        .animation(.default, value: vm.products.count)
        .scrollIndicators(.never)
        .refreshableTask {
            fetch()
        }
        .sheet($sheetAuth) {
            ConnectAuthView {
                fetch()
            }
        }
        .onChange(of: store.connectAccount?.id, fetch)
        .onChange(of: store.connectDemoMode, fetch)
        .onChange(of: store.connectRefreshToken, fetch)
    }
    
    private func fetch() {
        Task {
            if store.connectDemoMode {
                vm.products = [CiProduct.preview]
            } else {
                try? await vm.fetchProducts(store: store)
            }
        }
    }
}

#Preview {
    ConnectAppList()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
