import ScrechKit
import AppStoreConnect_Swift_SDK

struct AppLatestBuildView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let build: CiBuildRun
    let betaStates: [ExternalBetaState]

    var body: some View {
        if let number = build.attributes?.number {
            let status = AppBuildStatus(build, betaStates: betaStates)

            HStack(spacing: 4) {
                Image(systemName: status.symbol)
                    .foregroundStyle(status.color)
                    .accessibilityHidden(true)
                    .contentTransition(.opacity)

                Text(status.title(number: number))
                    .secondary()
                    .contentTransition(.opacity)
            }
            .animation(reduceMotion ? nil : .easeInOut, value: status)
            .animation(reduceMotion ? nil : .easeInOut, value: number)
            .footnote()
            .accessibilityElement(children: .combine)
        }
    }
}
