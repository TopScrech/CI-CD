import ScrechKit

struct CoolifyProjDetails: View {
    @State private var vm = CoolifyProjDetailsVM()
    
    private let proj: CoolifyProject
    
    init(_ proj: CoolifyProject) {
        self.proj = proj
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section("Apps") {
                ForEach(vm.apps) {
                    CoolifyAppCard($0)
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
        .navigationTitle(proj.name)
        .navSubtitle(proj.description ?? "")
        .refreshableTask {
            await vm.load(proj)
        }
        .task {
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
            
            TextField("New name", text: $vm.projDescription)
            
            Button("Save") {
                Task {
                    await vm.rename(proj.uuid)
                }
            }
        }
    }
}

#Preview {
    CoolifyProjDetails(PreviewProp.coolifyProj)
        .darkSchemePreferred()
}
