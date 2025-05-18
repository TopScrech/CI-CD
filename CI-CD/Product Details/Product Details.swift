import SwiftUI

struct ProductDetails: View {
    @Environment(ProjectVM.self) private var vm
    
    private let product: CIProduct
    
    init(_ product: CIProduct) {
        self.product = product
    }
    
    var body: some View {
        List {
            Section {
                ForEach(vm.builds) { build in
                    BuildCard(build)
                }
            }
        }
        .refreshableTask {
            try? await vm.fetchBuilds(product.id)
        }
    }
}

//#Preview {
//    ProductDetails()
//}
