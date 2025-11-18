import SwiftUI

struct CoolifyProjDetails: View {
    @State private var vm = CoolifyProjDetailsVM()
    
    private let proj: CoolifyProject
    
    init(_ proj: CoolifyProject) {
        self.proj = proj
    }
    
    var body: some View {
        List {
            ForEach(vm.apps) {
                CoolifyAppCard($0)
            }
        }
        .navigationTitle(proj.name)
        .refreshableTask {
            await vm.load(proj)
        }
    }
}

#Preview {
    CoolifyProjDetails(PreviewProp.coolifyProj)
        .darkSchemePreferred()
}
