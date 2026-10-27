import ScrechKit

struct ConnectUsageCardView: View {
    let plan: ConnectUsagePlan

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Xcode Cloud quota")

                Spacer()

                Text("\(plan.fractionUsed.formatted(.percent.precision(.fractionLength(0)))) of \(plan.totalHours.formatted(.number.precision(.fractionLength(0...1))))h used")
                    .secondary()
            }

            ProgressView(value: plan.progress)
                .progressViewStyle(ConnectUsageProgressStyle())
                .accessibilityLabel("Quota")
                .accessibilityValue(plan.fractionUsed.formatted(.percent.precision(.fractionLength(0))))

            if let resetDate = plan.resetOn {
                Text("Resets on \(resetDate.formatted(date: .abbreviated, time: .shortened))")
                    .footnote()
                    .secondary()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(.vertical, 4)
    }
}
