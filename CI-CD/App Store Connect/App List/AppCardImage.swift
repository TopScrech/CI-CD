import SwiftUI
import AppStoreConnect_Swift_SDK
import Kingfisher

struct AppCardImage: View {
    @Environment(AppVM.self) private var vm
    
    private let product: CiProduct
    
    init(_ product: CiProduct) {
        self.product = product
    }
    
    var body: some View {
        VStack {
            if let urlStrting = vm.iconURL, let url = URL(string: urlStrting) {
                KFImage(url)
                    .resizable()
                    .frame(32)
                    .clipShape(.rect(cornerRadius: 8))
            }
        }
        .animation(.default, value: vm.iconURL)
        .task {
            if let appId = product.relationships?.app?.data?.id {
                try? await vm.appBuilds(appId)
            }
        }
    }
}

#Preview {
    AppCardImage(CiProduct.preview)
        .darkSchemePreferred()
        .environment(AppVM())
}
