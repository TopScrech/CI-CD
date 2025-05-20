import SwiftUI
import AppStoreConnect_Swift_SDK

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

//#Preview {
//    IssueList()
//}
