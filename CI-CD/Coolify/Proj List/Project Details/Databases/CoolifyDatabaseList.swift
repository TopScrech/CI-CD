import SwiftUI

struct CoolifyDatabaseList: View {
    @Environment(CoolifyProjDetailsVM.self) private var vm
    
    var body: some View {
        if !vm.databases.isEmpty {
            Section("Databases") {
                ForEach(vm.databases) {
                    CoolifyDatabaseCard($0)
                }
            }
        }
    }
}

#Preview {
    List {
        CoolifyDatabaseList()
    }
    .darkSchemePreferred()
    .environment(CoolifyProjDetailsVM())
}
