import SwiftUI

struct CoolifyProjList: View {
    @State private var vm = CoolifyProjListVM()
    
    var body: some View {
        List {
            
        }
        .refreshableTask {
            await vm.fetchProjects()
        }
    }
}

#Preview {
    CoolifyProjList()
}
