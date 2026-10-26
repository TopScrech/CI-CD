import SwiftUI

struct WorkflowVersionAliasLabelView: View {
    let name: String
    let currentVersion: String?
    
    var body: some View {
        if let currentVersion {
            // The enclosing Picker handles selection using the option's tag
            Button {} label: {
                Text(name)
                Text("Currently \(currentVersion)")
            }
        } else {
            Text(name)
        }
    }
}
