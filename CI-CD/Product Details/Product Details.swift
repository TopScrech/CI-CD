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
                    Text(workflow.attributes?.name ?? "")
                        .contextMenu {
                            Button {
                                Task {
                                    try await vm.startBuild(workflow.id)
                                }
                            } label: {
                                Text("Start build")
                            }
                        }
                }
            }
            
            Section {
                ForEach(vm.builds) { build in
                    NavigationLink {
                        BuildDetails(build)
                    } label: {
                        BuildCard(build)
                    }
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
