import SwiftUI

struct HomeView: View {
    @State private var vm = ConnectVM()
    
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
    }
}

#Preview {
    HomeView()
}
