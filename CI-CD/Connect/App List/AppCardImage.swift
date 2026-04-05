import SwiftUI
import AppStoreConnect_Swift_SDK
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
                try? await vm.appBuilds(appId, store: store)
            }
        }
        .onChange(of: store.connectAccount?.id) {
            Task {
                if let appId = product.relationships?.app?.data?.id {
                    try? await vm.appBuilds(appId, store: store)
                }
            }
        }
        .onChange(of: store.connectRefreshToken) {
            Task {
                if let appId = product.relationships?.app?.data?.id {
                    try? await vm.appBuilds(appId, store: store)
                }
            }
        }
    }
}

#Preview {
    AppCardImage(CiProduct.preview)
        .darkSchemePreferred()
        .environment(AppVM())
}
