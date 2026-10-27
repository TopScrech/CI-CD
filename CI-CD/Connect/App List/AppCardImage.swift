import SwiftUI
import ASC
import Kingfisher

struct AppCardImage: View {
    @Environment(AppVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    private let product: CiProduct
    
    init(_ product: CiProduct) {
        self.product = product
    }
    
    var body: some View {
        VStack {
            if let urlString = vm.iconURL, let url = URL(string: urlString) {
                KFImage(url)
                    .diskCacheExpiration(.never)
                    .loadDiskFileSynchronously()
                    .waitForCache()
                    .resizable()
                    .frame(32)
                    .clipShape(.rect(cornerRadius: 8))
            }
        }
        .animation(.default, value: vm.iconURL)
        .task(id: "\(store.connectAccount?.id.uuidString ?? "").\(product.id).\(store.connectRefreshToken).\(store.connectDemoMode)") {
            if let appId = product.relationships?.app?.data?.id {
                try? await vm.appBuilds(appId, store: store)
            }
        }
    }
}

#Preview {
    AppCardImage(CiProduct.preview)
        .darkSchemePreferred()
        .environment(AppVM())
}
