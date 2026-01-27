import SwiftUI
import AppStoreConnect_Swift_SDK

struct AppVersions: View {
    @Environment(AppVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
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
            await load()
        }
        .task {
            await load()
        }
        .onChange(of: store.connectAccount?.id) {
            Task {
                await load()
            }
        }
        .onChange(of: store.connectDemoMode) {
            Task {
                await load()
            }
        }
        .onChange(of: store.connectRefreshToken) {
            Task {
                await load()
            }
        }
    }

    private func load() async {
        if store.connectDemoMode {
            vm.versions = [AppStoreVersion.preview]
            return
        }

        try? await vm.getVersions(appId, store: store)
    }
}

#Preview {
    NavigationStack {
        AppVersions("dev.topscrech.Goida", for: "Preview")
    }
    .darkSchemePreferred()
    .environment(AppVM())
}
