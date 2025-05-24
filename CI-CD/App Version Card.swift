import SwiftUI
import AppStoreConnect_Swift_SDK

struct AppVersionCard: View {
    private let version: AppStoreVersion
    
    init(_ version: AppStoreVersion) {
        self.version = version
    }
    
    @State private var adpId: String?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(version.attributes?.versionString ?? "-")
                    .title3(.semibold)
                
                if let adpId {
                    Text(adpId)
                        .footnote()
                        .secondary()
                }
            }
            
            Spacer()
            
            if let adpId {
                Button {
                    UIPasteboard.general.string = adpId
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .semibold()
                }
            }
        }
        .foregroundStyle(.foreground)
        .onFirstAppear {
            try? await getADPKey(version.id)
        }
    }
    
    private func getADPKey(_ notarizationId: String) async throws {
        guard let provider = try await provider() else {
            return
        }
        
        let request = APIEndpoint.v1
            .appStoreVersions
            .id(notarizationId)
            .alternativeDistributionPackage
            .get()
        
        do {
            let adpKey = try await provider.request(request).data
            adpId = adpKey.id
        } catch {
            print(error)
            throw error
        }
    }
}

#Preview {
    List {
        AppVersionCard(AppStoreVersion.preview)
    }
    .darkSchemePreferred()
}
