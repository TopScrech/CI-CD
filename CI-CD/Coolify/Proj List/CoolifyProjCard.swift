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
            VStack(alignment: .leading) {
                Text(proj.name)
                
                if let description = proj.description, !description.isEmpty {
                    Text(description)
                        .footnote()
                        .secondary()
                }
            }
        }
#if DEBUG
        .contextMenu {
            Button("Print", systemImage: "hammer") {
                print(proj)
            }
        }
#endif
    }
}

#Preview {
    CoolifyProjCard(PreviewProp.coolifyProj)
        .darkSchemePreferred()
}
