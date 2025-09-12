import SwiftUI
import AppStoreConnect_Swift_SDK

struct ActionDetails: View {
    @Environment(ActionVM.self) private var vm
    
    var body: some View {
        TabView {
            IssueList()
                .tag(0)
                .tabItem {
                    Label("Issues", systemImage: "exclamationmark.triangle")
                }
            
            ArtifactList()
                .tag(1)
                .tabItem {
                    Label("Artifacts", systemImage: "archivebox")
                }
        }
        .environment(vm)
    }
}

#Preview {
    ActionDetails()
        .darkSchemePreferred()
        .environment(ActionVM())
}
