import SwiftUI

struct ProductDetails: View {
    @State private var vm = ProjectDetailsVM()
    
    private let product: CIProduct
    
    init(_ product: CIProduct) {
        self.product = product
    }
    
    var body: some View {
        List {
            Section {
                ForEach(vm.builds) { build in
                    Text(build.attributes.number)
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
