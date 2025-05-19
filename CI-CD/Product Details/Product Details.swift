import SwiftUI
import AppStoreConnect_Swift_SDK

struct ProductDetails: View {
    @Environment(ProductVM.self) private var vm
    
    private let product: CiProduct
    
    init(_ product: CiProduct) {
        self.product = product
    }
    
    var body: some View {
        List {
            Section {
                ForEach(vm.workflows) { workflow in
                    WorkflowCard(workflow)
                }
            }
            
            Section {
                ForEach(vm.builds.reversed()) { build in
                    BuildCard(build)
                }
                .animation(.default, value: vm.builds.count)
            }
        }
        .environment(vm)
        .refreshableTask {
            try? await vm.fetchBuilds(product.id)
        }
    }
}

//#Preview {
//    ProductDetails()
//}
