import SwiftUI

struct CoolifyDeploymentCardStatus: View {
    private let status: DeploymentStatus
    
    init(_ status: DeploymentStatus) {
        self.status = status
    }
    
    private var statusText: String {
        switch status {
        case .finished: "Success"
        default: status.rawValue
        }
    }
    
    var body: some View {
        Text(statusText)
    }
}

#Preview {
    CoolifyDeploymentCardStatus(.finished)
}
