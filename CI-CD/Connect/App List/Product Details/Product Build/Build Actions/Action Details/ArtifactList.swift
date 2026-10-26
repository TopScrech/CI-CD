import SwiftUI

struct ArtifactList: View {
    @Environment(ActionVM.self) private var vm
    
    var body: some View {
        List {
            ForEach(vm.artifacts) {
                ArtifactCard($0)
            }
        }
        .navigationTitle("Artifacts")
        .overlay {
            if vm.artifacts.isEmpty {
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
