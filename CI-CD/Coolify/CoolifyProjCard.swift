import SwiftUI

struct CoolifyProjCard: View {
    private let proj: CoolifyProject
    
    init(_ proj: CoolifyProject) {
        self.proj = proj
    }
    
    var body: some View {
        NavigationLink {
            CoolifyProjDetails(proj)
        } label: {
            VStack {
                Text(proj.name)
                
                if let description = proj.description, !description.isEmpty {
                    Text(description)
                        .footnote()
                        .secondary()
                }
            }
        }
    }
}

#Preview {
#warning("Create Previewprop")
    CoolifyProjCard(
        CoolifyProject(id: 1, uuid: "", name: "Test", description: "Test", environments: [])
    )
    .darkSchemePreferred()
}
