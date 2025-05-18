import SwiftUI

struct ProductCard: View {
    @State private var vm = ProductVM()
    
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
        .contextMenu {
            Menu {
                Button {
                    UIPasteboard.general.string = vm.workflows.first?.id
                } label: {
                    Label("Copy first workflow id", systemImage: "doc.on.doc")
                }
            } label: {
                Label("Debug", systemImage: "hammer")
            }
        }
    }
}

//#Preview {
//    ProductCard()
//}
