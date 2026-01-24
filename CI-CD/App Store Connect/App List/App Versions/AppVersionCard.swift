import SwiftUI
import AppStoreConnect_Swift_SDK

struct AppVersionCard: View {
    @State private var vm = AppVersionCardVM()
    
    private let version: AppStoreVersion
    
    init(_ version: AppStoreVersion) {
        self.version = version
    }
    
    private var versionString: String? {
        version.attributes?.versionString
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(versionString ?? "-")
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
            
            if vm.adpId != nil {
                if !vm.isProcessing, let url = vm.downloadUrl {
                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.up")
                            .title3(.semibold)
                            .foregroundStyle(.green)
                    }
                    
                } else if !vm.isProcessing {
                    Button(action: startProcessing) {
                        Image(systemName: "square.and.arrow.down")
                            .title3(.semibold)
                    }
                    
                } else if vm.isProcessing {
                    ProgressView()
                }
            }
        }
        .animation(.default, value: vm.adpId)
        .foregroundStyle(.primary)
        .task {
            if vm.adpId == nil {
                try? await vm.getADPKey(version.id)
            }
        }
    }
    
    private func startProcessing() {
        Task {
            await vm.startProcessing(versionString)
        }
    }
}

#Preview {
    List {
        AppVersionCard(AppStoreVersion.preview)
    }
    .darkSchemePreferred()
}
