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
    }
}

#Preview {
    ArtifactList()
        .environment(ActionVM())
}
