import ScrechKit

struct CoolifyProjDetails: View {
    @Environment(CoolifyProjDetailsVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
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
            load()
        }
        .onChange(of: store.coolifyAccount?.id) {
            load()
        }
        .onChange(of: store.coolifyDemoMode) {
            load()
        }
        .onChange(of: store.coolifyRefreshToken) {
            load()
        }
        .toolbar {
            Menu {
                Button("Rename", systemImage: "pencil") {
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
            Button("Cancel") {}
            AsyncButton("Save", action: save)
        }
    }
    
    private func save() async {
        if let updated = await vm.rename(proj.uuid, store: store) {
            proj = updated
            await vm.load(updated.uuid, store: store)
        }
    }
    
    private func load() {
        Task {
            await vm.load(proj.uuid, store: store)
        }
    }
}

#Preview {
    CoolifyProjDetails(Preview.coolifyProj)
        .darkSchemePreferred()
        .environment(CoolifyProjDetailsVM())
}
