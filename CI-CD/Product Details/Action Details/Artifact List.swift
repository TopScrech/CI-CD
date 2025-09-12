import SwiftUI

struct ArtifactList: View {
    @Environment(ActionVM.self) private var vm
    
    var body: some View {
        List {
            ForEach(vm.artifacts) { artifact in
                ArtifactCard(artifact)
            }
        }
        .navigationTitle("Artifacts")
        .overlay {
            if vm.issues.isEmpty {
                ContentUnavailableView("No artifacts found", systemImage: "archivebox")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ArtifactList()
    }
    .darkSchemePreferred()
    .environment(ActionVM())
}
