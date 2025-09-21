import SwiftUI

struct CoolifyProjDetails: View {
    private let proj: CoolifyProject
    
    init(_ proj: CoolifyProject) {
        self.proj = proj
    }
    
    var body: some View {
        List {
            
        }
        .navigationTitle(proj.name)
        .navigationTitle(proj.description ?? "")
    }
}

//#Preview {
//    CoolifyProjDetails()
//}
