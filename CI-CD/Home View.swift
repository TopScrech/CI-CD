import ScrechKit

struct HomeView: View {
    @State private var vm = ConnectVM()
    
    @State private var sheetSettings = false
    
    var body: some View {
        List {
            ForEach(vm.products) { product in
                ProductCard(product)
            }
            .animation(.default, value: vm.products.count)
        }
        .navigationTitle("CI/CD")
        .scrollIndicators(.never)
        .refreshableTask {
            try? await vm.fetchProducts()
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
    HomeView()
}
