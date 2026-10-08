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
                ProjectListCredentialsUnavailableView(serviceName: "Coolify") {
                    sheetAuth = true
                }
            }
        }
        .environment(vm)
        .refreshableTask {
            refreshProjects()
        }
        .task {
            refreshProjects()
        }
        .onChange(of: store.coolifyAccount?.id) {
            refreshProjects()
        }
        .onChange(of: store.coolifyDemoMode) {
            refreshProjects()
        }
        .onChange(of: store.coolifyRefreshToken) {
            refreshProjects()
        }
        .sheet($sheetAuth) {
            CoolifyAuthView {
                refreshProjects()
            }
        }
    }
    
    private func refreshProjects() {
        if store.coolifyDemoMode {
            vm.projects = [Preview.coolifyProj]
            return
        }
        
        Task {
            await vm.fetchProjects(store: store)
        }
    }
}

#Preview {
    CoolifyProjList()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
