import ScrechKit

struct ConnectUsageCardView: View {
    let plan: ConnectUsagePlan

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Quota")

                Spacer()

                Text("\(plan.fractionUsed.formatted(.percent.precision(.fractionLength(0)))) of \(plan.totalHours.formatted(.number.precision(.fractionLength(0...1))))h used")
                    .secondary()
            }

            ProgressView(value: plan.progress)
                .progressViewStyle(ConnectUsageProgressStyle())
                .accessibilityLabel("Quota")
                .accessibilityValue(plan.fractionUsed.formatted(.percent.precision(.fractionLength(0))))
        }
        .padding(.vertical)
    }
}
