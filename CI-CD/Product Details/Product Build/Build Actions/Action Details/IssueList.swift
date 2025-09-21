import SwiftUI

struct IssueList: View {
    @Environment(ActionVM.self) private var vm
    
    var body: some View {
        List {
            ForEach(vm.issues) {
                IssueCard($0)
            }
        }
        .navigationTitle("Issues")
        .overlay {
            if vm.issues.isEmpty {
                ContentUnavailableView("No issues found", systemImage: "checkmark.seal", description: Text("Your code is great!"))
            }
        }
    }
}

#Preview {
    NavigationStack {
        IssueList()
    }
    .darkSchemePreferred()
    .environment(ActionVM())
}
