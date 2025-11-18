import ScrechKit

struct DeploymentCard: View {
    private let deployment: CoolifyDeployment
    
    init(_ deployment: CoolifyDeployment) {
        self.deployment = deployment
    }
    
    var body: some View {
        HStack {
            Capsule()
                .fill(deployment.status.color.gradient)
                .frame(width: 3, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                DeploymentCardStatus(deployment.status)
                
                if let branch = deployment.branch {
                    Text(branch)
                        .footnote()
                        .secondary()
                }
                
                if let created = deployment.createdAt {
                    Text(created)
                        .footnote()
                        .secondary()
                }
                
                if let message = deployment.message, !message.isEmpty {
                    Text(message)
                        .footnote()
                        .secondary()
                }
            }
        }
    }
}

//#Preview {
//    List {
//        DeploymentCard()
//    }
//    .darkSchemePreferred()
//}
