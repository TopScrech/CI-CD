import SwiftUI

struct WorkflowVersionOptionsView: View {
    let options: [WorkflowVersionOption]
    let catalog: [WorkflowVersionOption]

    var body: some View {
        if options.contains(where: \.isAlias) {
            Section("Aliases") {
                ForEach(options.filter(\.isAlias)) { option in
                    WorkflowVersionAliasLabelView(
                        name: option.name,
                        currentVersion: option.currentVersion(in: catalog)
                    )
                    .tag(Optional(option.id))
                }
            }
        }

        Section("Versions") {
            ForEach(options.filter { !$0.isAlias }) {
                Text($0.name)
                    .tag(Optional($0.id))
            }
        }
    }
}
