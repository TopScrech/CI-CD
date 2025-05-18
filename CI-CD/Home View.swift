import SwiftUI

struct HomeView: View {
    @State private var vm = AppStoreAuth()
    
    var body: some View {
        List {
            ForEach(vm.ciProducts) { product in
                ProductCard(product)
            }
        }
        .refreshableTask {
            try? await vm.fetchApps()
        }
    }
}

#Preview {
    HomeView()
}
