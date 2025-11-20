import SwiftUI

struct CoolifyProjList: View {
    @State private var vm = CoolifyProjListVM()
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetAuth = false
    
    var body: some View {
        List {
            if store.coolifyAuthorized {
                ForEach(vm.projects) {
                    CoolifyProjCard($0)
                }
            } else {
                ContentUnavailableView("Coolify credentials missing", systemImage: "key.card")
                
                Section {
                    Button("Provide credentials") {
                        sheetAuth = true
                    }
                }
            }
        }
        .environment(vm)
        .refreshableTask {
            await vm.fetchProjects()
        }
        .sheet($sheetAuth) {
            CoolifyAuthView {
                await vm.fetchProjects()
            }
        }
    }
}

#Preview {
    CoolifyProjList()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
