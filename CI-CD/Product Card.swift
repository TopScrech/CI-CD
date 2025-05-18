import SwiftUI

struct ProductCard: View {
    @State private var vm = ProjectVM()
    
    private let product: CIProduct
    
    init(_ product: CIProduct) {
        self.product = product
    }
    
    var body: some View {
        NavigationLink {
            ProductDetails(product)
                .environment(vm)
        } label: {
            VStack(alignment: .leading) {
                Text(product.attributes.name)
                    .title3()
                
                Text("Workflows: \(vm.workflows.map(\.attributes.name))")
                    .secondary()
                    .footnote()
            }
        }
        .task {
            try? await vm.fetchWorkflows(product.id)
        }
    }
}

//#Preview {
//    ProductCard()
//}
