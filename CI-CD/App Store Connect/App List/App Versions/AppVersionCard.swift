import SwiftUI
import AppStoreConnect_Swift_SDK

struct AppVersionCard: View {
    @State private var vm = AppVersionCardVM()
    @EnvironmentObject private var store: ValueStore
    
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
                if !vm.isProcessing, let url = vm.downloadURL {
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
            load()
        }
        .onChange(of: store.connectAccount?.id) {
            vm.reset()
            load()
        }
        .onChange(of: store.connectDemoMode) {
            vm.reset()
            load()
        }
        .onChange(of: store.connectRefreshToken) {
            vm.reset()
            load()
        }
    }
    
    private func startProcessing() {
        Task {
            await vm.startProcessing(versionString)
        }
    }

    private func load() {
        Task {
            guard !store.connectDemoMode else { return }

            if vm.adpId == nil {
                try? await vm.getADPKey(version.id, store: store)
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
