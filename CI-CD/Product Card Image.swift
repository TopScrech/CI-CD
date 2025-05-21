import SwiftUI
import Kingfisher

struct ProductCardImage: View {
    @Environment(ProductVM.self) private var vm
    
    private let bundleId: String?
    
    init(_ bundleId: String?) {
        self.bundleId = bundleId
    }
    
    @State private var iconUrl: URL?
    
    var body: some View {
        VStack {
            if let iconUrl {
                KFImage(iconUrl)
                    .resizable()
                    .frame(32)
                    .clipShape(.rect(cornerRadius: 8))
            }
        }
        .task {
            if iconUrl == nil {
                iconUrl = try? await vm.fetchIconUrl(bundleId)
            }
        }
    }
}

#Preview {
    ProductCardImage("host.bisquit.Bisquit-host")
        .environment(ProductVM())
}
