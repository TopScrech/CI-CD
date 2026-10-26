import ScrechKit
import AppStoreConnect_Swift_SDK

struct AppLatestBuildView: View {
    let build: CiBuildRun

    var body: some View {
        if let number = build.attributes?.number {
            let status = AppBuildStatus(build)

            HStack(spacing: 4) {
                Image(systemName: status.symbol)
                    .foregroundStyle(status.color)
                    .accessibilityHidden(true)

                Text(status.title(number: number))
                    .secondary()
            }
            .font(.footnote)
            .accessibilityElement(children: .combine)
        }
    }
}
