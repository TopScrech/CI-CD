import SwiftUI

struct CoolifyProjCard: View {
    @State private var projDetailsVM = CoolifyProjDetailsVM()
    @Environment(CoolifyProjListVM.self) private var vm
    
    private let proj: CoolifyProject
    
    init(_ proj: CoolifyProject) {
        self.proj = proj
    }
    
    @State private var alertRename = false
    
    var body: some View {
        NavigationLink {
            CoolifyProjDetails(proj)
                .environment(projDetailsVM)
        } label: {
            VStack(alignment: .leading) {
                Text(proj.name)
                
                if let description = proj.description, !description.isEmpty {
                    Text(description)
                        .footnote()
                        .secondary()
                }
            }
        }
        .task {
            projDetailsVM.projName = proj.name
            projDetailsVM.projDescription = proj.description ?? ""
        }
        .contextMenu {
            Button("Rename", systemImage: "pencil") {
                alertRename = true
            }
#if DEBUG
            Button("Print", systemImage: "hammer") {
                print(proj)
            }
#endif
        }
        .alert("Rename", isPresented: $alertRename) {
            TextField("New name", text: $projDetailsVM.projName)
                .autocorrectionDisabled()
            
            TextField("New description", text: $projDetailsVM.projDescription)
            
            Button("Save", role: .cancel) {
                save()
            }
        }
    }
    
    private func save() {
        Task {
            if let _ = await projDetailsVM.rename(proj.uuid) {
                await vm.fetchProjects()
            }
        }
    }
}

#Preview {
    CoolifyProjCard(Preview.coolifyProj)
        .environment(CoolifyProjListVM())
        .environment(CoolifyProjDetailsVM())
        .darkSchemePreferred()
}
