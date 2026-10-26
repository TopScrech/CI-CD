import ScrechKit
import AppStoreConnect_Swift_SDK

struct ConnectAppList: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var vm = AppListVM()
    @State private var usageVM = ConnectUsageVM()
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetAuth = false
    
    var body: some View {
        let products = vm.visibleProducts(hidingRemovedApps: store.connectHideRemovedApps && !store.connectDemoMode)

        List {
            if store.connectDemoMode || store.connectAuthorized {
                if #available(iOS 26, macOS 26, visionOS 26, *), !store.connectDemoMode {
                    ConnectUsageSectionView()
                }

                Section {
                    ForEach(products) {
                        AppCard($0)
                            .environment(vm.appViewModel(for: $0.id))
                    }
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
        .animation(reduceMotion ? nil : .default, value: products.map(\.id))
        .scrollIndicators(.never)
        .environment(usageVM)
        .task(id: "\(store.connectAccount?.id.uuidString ?? "").\(store.connectDemoMode).\(store.connectRefreshToken)") {
            await loadUsage()
        }
        .refreshableTask {
            fetch()
            await loadUsage()
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
    
    private func loadUsage() async {
        guard !store.connectDemoMode, let accountID = store.connectAccount?.id else {
            usageVM.reset()
            return
        }
        if #available(iOS 26, macOS 26, visionOS 26, *) {
            await usageVM.load(accountID: accountID)
        }
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
