import SwiftUI

struct CoolifyProjList: View {
    @State private var vm = CoolifyProjListVM()
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetAuth = false
    
    var body: some View {
        List {
            if store.coolifyDemoMode || store.coolifyAuthorized {
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
            await refreshProjects()
        }
        .sheet($sheetAuth) {
            CoolifyAuthView {
                await refreshProjects()
            }
        }
    }
    
    private func refreshProjects() async {
        if store.coolifyDemoMode {
            vm.projects = [Preview.coolifyProj]
        } else {
            await vm.fetchProjects()
        }
    }
}

#Preview {
    CoolifyProjList()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
