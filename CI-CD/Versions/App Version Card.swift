import SwiftUI
import AppStoreConnect_Swift_SDK

struct AppVersionCard: View {
    @Bindable private var vm = AppVersionCardVM()
    
    private let version: AppStoreVersion
    
    init(_ version: AppStoreVersion) {
        self.version = version
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(version.attributes?.versionString ?? "-")
                    .title3(.semibold)
                
                if let adpId = vm.adpId {
                    Text(adpId)
                        .footnote()
                        .secondary()
                }
                
                if let errorMessage = vm.errorMessage {
                    Text(errorMessage)
                        .footnote()
                        .foregroundStyle(.red)
                }
            }
            
            Spacer()
            
            if !vm.isProcessing, vm.downloadUrl.isEmpty {
                Button {
                    Task {
                        await vm.startProcessing()
                    }
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .title3(.semibold)
                }
                
            } else if vm.isProcessing {
                ProgressView()
                
            } else if !vm.isProcessing, !vm.downloadUrl.isEmpty {
                Button {
                    vm.safariCover = true
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .title3(.semibold)
                }
            }
        }
        .animation(.default, value: vm.adpId)
        .foregroundStyle(.primary)
        .safariCover($vm.safariCover, url: vm.downloadUrl)
        .task {
            if vm.adpId == nil {
                try? await vm.getADPKey(version.id)
            }
        }
    }
}

#Preview {
    List {
        AppVersionCard(AppStoreVersion.preview)
    }
    .darkSchemePreferred()
}
