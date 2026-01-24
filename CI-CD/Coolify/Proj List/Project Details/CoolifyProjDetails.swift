import ScrechKit

struct CoolifyProjDetails: View {
    @Environment(CoolifyProjDetailsVM.self) private var vm
    
    @State private var proj: CoolifyProject
    
    init(_ proj: CoolifyProject) {
        _proj = State(initialValue: proj)
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section("Apps") {
                ForEach(vm.apps) {
                    CoolifyAppCard($0)
                }
            }
            
            CoolifyDatabaseList()
                .environment(vm)
        }
        .navigationTitle(proj.name)
        .navSubtitle(proj.description ?? "")
        .refreshableTask {
            await vm.load(proj.uuid)
        }
        .toolbar {
            Menu {
                Button("Rename") {
                    vm.alertRename = true
                }
            } label: {
                Image(systemName: "ellipsis")
            }
        }
        .alert("Rename", isPresented: $vm.alertRename) {
            TextField("New name", text: $vm.projName)
                .autocorrectionDisabled()
            
            TextField("New description", text: $vm.projDescription)
            Button("Save", action: save)
        }
    }
    
    private func save() {
        Task {
            if let updated = await vm.rename(proj.uuid) {
                proj = updated
                await vm.load(updated.uuid)
            }
        }
    }
}

#Preview {
    CoolifyProjDetails(Preview.coolifyProj)
        .darkSchemePreferred()
        .environment(CoolifyProjDetailsVM())
}
