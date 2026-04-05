import SwiftUI
import AppStoreConnect_Swift_SDK

struct ActionDetails: View {
    @Environment(ActionVM.self) private var vm
    
    var body: some View {
        TabView {
            Tab("Issues", systemImage: "exclamationmark.triangle") {
                IssueList()
            }
            
            Tab("Artifacts", systemImage: "archivebox") {
                ArtifactList()
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
