import SwiftUI

struct CoolifyProjList: View {
    @State private var vm = CoolifyProjListVM()
    
    var body: some View {
        List {
            ForEach(vm.projects) {
                CoolifyProjCard($0)
            }
        }
        .refreshableTask {
            await vm.fetchProjects()
        }
    }
}

#Preview {
    CoolifyProjList()
        .darkSchemePreferred()
}
