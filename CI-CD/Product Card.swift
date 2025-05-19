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
            HStack {
                if let attributes = product.attributes, let name = attributes.name {
                    Text(name)
                        .title3()
                }
                
                Spacer()
                
                ForEach(vm.workflows) { workflow in
                    Text(workflow.attributes?.name ?? "")
                        .secondary()
                        .footnote()
                }
            }
        }
        .task {
            try? await vm.fetchWorkflows(product.id)
        }
        //        .contextMenu {
        //            Button {
        //                Task {
        //                    try await vm.startBuild(product.id)
        //                }
        //            } label: {
        //                Label("Start build", systemImage: "play")
        //            }
        //        }
    }
}

//#Preview {
//    ProductCard()
//}
