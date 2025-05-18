import ScrechKit

struct HomeView: View {
    @State private var vm = ConnectVM()
    
    @State private var sheetSettings = false
    
    var body: some View {
        List {
            ForEach(vm.products) { product in
                ProductCard(product)
            }
        }
        .navigationTitle("CI/CD")
        .refreshableTask {
            try? await vm.fetchProducts()
        }
        .sheet($sheetSettings) {
            
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
