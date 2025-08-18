import ScrechKit
import AppStoreConnect_Swift_SDK

struct AppListView: View {
    @State private var vm = AppListVM()
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetSettings = false
    
    var body: some View {
        List {
            ForEach(vm.products) { product in
                AppCard(product)
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
        .sheet($sheetSettings) {
            NavigationView {
                AppSettings()
            }
        }
        .toolbar {
            SFButton("gear") {
                sheetSettings = true
            }
        }
    }
}

#Preview {
    AppListView()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
