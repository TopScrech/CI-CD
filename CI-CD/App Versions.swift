import SwiftUI
import AppStoreConnect_Swift_SDK

struct AppVersions: View {
    @Environment(AppVM.self) private var vm
    
    private let appId: String
    
    init(_ appId: String) {
        self.appId = appId
    }
    
    var body: some View {
        List(vm.versions) { version in
            if version.attributes?.platform == .ios {
                AppVersionCard(version)
            }
        }
        .navigationTitle("AltStore Helper")
        .refreshableTask {
            try? await vm.getVersions(appId)
        }
    }
}

#Preview {
    AppVersions("")
}
