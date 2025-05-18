import SwiftUI

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
            Button {
                sheetSettings = true
            } label: {
                Image(systemName: "gear")
            }
        }
    }
}

#Preview {
    HomeView()
}
