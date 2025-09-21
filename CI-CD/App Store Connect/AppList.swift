import ScrechKit
import AppStoreConnect_Swift_SDK

struct AppList: View {
    @State private var vm = AppListVM()
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
            ForEach(vm.products) {
                AppCard($0)
            }
        }
        .animation(.default, value: vm.products.count)
        .scrollIndicators(.never)
        .refreshableTask {
            if store.demoMode {
                vm.products = [CiProduct.preview]
            } else {
                try? await vm.fetchProducts()
            }
        }
    }
}

#Preview {
    AppList()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
