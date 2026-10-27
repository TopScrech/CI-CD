import ScrechKit

struct WorkflowVersionPicker: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    @Binding var selection: String?
    let options: [WorkflowVersionOption]
    let catalog: [WorkflowVersionOption]
    let currentVersion: String?
    let isLoading: Bool

    var body: some View {
        LabeledContent(title) {
            ZStack(alignment: .trailing) {
                ProgressView()
                    .accessibilityLabel("Loading \(title) versions")
                    .opacity(isLoading ? 1 : 0)
                    .accessibilityHidden(!isLoading)
                    .allowsHitTesting(false)

                VStack(alignment: .trailing) {
                    Picker(title, selection: $selection) {
                        if !options.contains(where: { $0.id == selection }) {
                            Text(selection == nil ? "Select a version" : "Current version (unavailable)")
                                .tag(selection)
                        }

                        WorkflowVersionOptionsView(options: options, catalog: catalog)
                    }
                    .labelsHidden()
                    .disabled(isLoading || options.isEmpty)

                    if let currentVersion {
                        Text("Currently \(currentVersion)")
                            .footnote()
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .opacity(isLoading ? 0 : 1)
                .accessibilityHidden(isLoading)
                .allowsHitTesting(!isLoading)
            }
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: isLoading)
        }
    }
}
