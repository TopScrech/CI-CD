import SwiftUI

struct BuildCard: View {
    private let build: CIBuildRun
    
    init(_ build: CIBuildRun) {
        self.build = build
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(build.attributes.number)
            }
        }
    }
}

//#Preview {
//    BuildCard()
//}
