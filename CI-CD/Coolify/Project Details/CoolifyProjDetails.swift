import ScrechKit

struct CoolifyProjDetails: View {
    @State private var vm = CoolifyProjDetailsVM()
    @State private var proj: CoolifyProject
    
    init(_ proj: CoolifyProject) {
        _proj = State(initialValue: proj)
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section("Apps") {
                ForEach(vm.apps) { app in
                    NavigationLink {
                        CoolifyAppDetails(app)
                    } label: {
                        CoolifyAppCard(app)
                    }
                }
            }
            
            if !vm.databases.isEmpty {
                Section("Databases") {
                    ForEach(vm.databases) {
                        CoolifyDatabaseCard($0)
                    }
                }
            }
        }
        .navigationTitle(vm.project?.name ?? proj.name)
        .navSubtitle(vm.project?.description ?? proj.description ?? "")
        .refreshableTask {
            await vm.load(vm.project ?? proj)
        }
        .task {
            vm.project = proj
            vm.projName = proj.name
            vm.projDescription = proj.description ?? ""
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
            
            Button("Save") {
                Task {
                    if let updated = await vm.rename(proj.uuid) {
                        vm.project = updated
                        proj = updated
                        await vm.load(updated)
                    }
                }
            }
        }
    }
}

#Preview {
    CoolifyProjDetails(PreviewProp.coolifyProj)
        .darkSchemePreferred()
}
