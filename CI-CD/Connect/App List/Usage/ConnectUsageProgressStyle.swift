import SwiftUI

struct ConnectUsageProgressStyle: ProgressViewStyle {
    @ScaledMetric private var height = 20

    func makeBody(configuration: Configuration) -> some View {
        Rectangle()
            .fill(.quaternary)
            .overlay {
                Rectangle()
                    .fill(.blue)
                    .scaleEffect(x: configuration.fractionCompleted ?? 0, anchor: .leading)
            }
            .frame(height: height)
            .clipShape(.rect(cornerRadius: 6))
    }
}
