import ASC

extension CiBuildAction {
    var isPendingBetaReview: Bool {
        attributes?.completionStatus == nil
            && attributes?.executionProgress == .running
            && attributes?.name?.hasPrefix("TestFlight External Testing") == true
    }
}
