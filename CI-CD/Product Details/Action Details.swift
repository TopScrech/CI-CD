import SwiftUI
import AppStoreConnect_Swift_SDK

struct ActionDetails: View {
    @Environment(ActionVM.self) private var vm
    
    var body: some View {
        TabView {
            List {
                ForEach(vm.issues) { issue in
                    IssueCard(issue)
                }
            }
            .navigationTitle("Issues")
            .tag(0)
            .tabItem {
                Label("Issues", systemImage: "exclamationmark.triangle")
            }
            
            List {
                ForEach(vm.artifacts) { artifact in
                    ArtifactCard(artifact)
                }
            }
            .navigationTitle("Artifacts")
            .tag(1)
            .tabItem {
                Label("Artifacts", systemImage: "archivebox")
            }
        }
    }
}

#Preview {
    ActionDetails()
        .environment(ActionVM())
}
