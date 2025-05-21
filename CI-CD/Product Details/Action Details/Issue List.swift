import SwiftUI

struct IssueList: View {
    @Environment(ActionVM.self) private var vm
    
    var body: some View {
        List {
            ForEach(vm.issues) { issue in
                IssueCard(issue)
            }
        }
        .navigationTitle("Issues")
    }
}

#Preview {
    IssueList()
        .environment(ActionVM())
}
