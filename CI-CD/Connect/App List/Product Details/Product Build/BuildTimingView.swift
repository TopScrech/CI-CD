import SwiftUI
import AppStoreConnect_Swift_SDK

struct BuildTimingView: View {
    @Environment(BuildVM.self) private var vm

    let build: CiBuildRun

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            LabeledContent("Duration") {
                if let duration = vm.duration(of: build, now: context.date) {
                    Text(duration, format: .units(allowed: [.hours, .minutes, .seconds], width: .abbreviated))
                } else {
                    Text("—")
                }
            }
            .monospacedDigit()
        }
    }
}
