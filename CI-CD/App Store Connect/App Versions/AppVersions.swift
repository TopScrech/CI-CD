import SwiftUI
import AppStoreConnect_Swift_SDK

struct AppVersions: View {
    @Environment(AppVM.self) private var vm
    
    private let appId: String
    private let name: String?
    
    init(_ appId: String, for name: String?) {
        self.appId = appId
        self.name = name
    }
    
    var body: some View {
        List(vm.versions) { version in
            if version.attributes?.platform == .ios {
                AppVersionCard(version)
            }
        }
        .navigationTitle("AltStore Helper")
        .navSubtitle(name ?? "")
        .scrollIndicators(.never)
        .refreshableTask {
            try? await vm.getVersions(appId)
        }
    }
}

#Preview {
    NavigationStack {
        AppVersions("dev.topscrech.Goida", for: "Preview")
    }
    .darkSchemePreferred()
    .environment(AppVM())
}
