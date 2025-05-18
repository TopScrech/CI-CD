import SwiftUI
import AppStoreConnect_Swift_SDK

struct ProductCard: View {
    @State private var vm = ProductVM()
    
    private let product: CiProduct
    
    init(_ product: CiProduct) {
        self.product = product
    }
    
    var body: some View {
        NavigationLink {
            ProductDetails(product)
                .environment(vm)
        } label: {
            VStack(alignment: .leading) {
                if let attributes = product.attributes, let name = attributes.name {
                    Text(name)
                        .title3()
                }
                
//                Text("Workflows: \(vm.workflows.map(\.attributes.name))")
//                    .secondary()
//                    .footnote()
            }
        }
        .task {
            try? await vm.fetchWorkflows(product.id)
        }
//        .contextMenu {
//            Menu {
//                Button {
//                    UIPasteboard.general.string = vm.workflows.first?.id
//                } label: {
//                    Label("Copy first workflow id", systemImage: "doc.on.doc")
//                }
//            } label: {
//                Label("Debug", systemImage: "hammer")
//            }
//        }
    }
}

//#Preview {
//    ProductCard()
//}
