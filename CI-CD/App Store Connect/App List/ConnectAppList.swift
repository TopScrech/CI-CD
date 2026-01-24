import ScrechKit
import AppStoreConnect_Swift_SDK

struct ConnectAppList: View {
    @State private var vm = AppListVM()
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetAuth = false
    
    var body: some View {
        List {
            if store.connectDemoMode || store.connectAuthorized {
                ForEach(vm.products) {
                    AppCard($0)
                }
            } else {
                ContentUnavailableView("App Store Connect credentials missing", systemImage: "key.card")
                
                Section {
                    Button("Provide credentials") {
                        sheetAuth = true
                    }
                }
            }
        }
        .animation(.default, value: vm.products.count)
        .scrollIndicators(.never)
        .sheet($sheetAuth) {
            ConnectAuthView {
                fetch()
            }
        }
        .refreshableTask {
            fetch()
        }
    }
    
    private func fetch() {
        Task {
            if store.connectDemoMode {
                vm.products = [CiProduct.preview]
            } else {
                try? await vm.fetchProducts()
            }
        }
    }
}

#Preview {
    ConnectAppList()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
