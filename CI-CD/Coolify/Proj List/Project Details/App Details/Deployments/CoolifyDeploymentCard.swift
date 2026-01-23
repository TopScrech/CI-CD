import ScrechKit

struct CoolifyDeploymentCard: View {
    private let deployment: CoolifyDeployment
    
    init(_ deployment: CoolifyDeployment) {
        self.deployment = deployment
    }
    
    var body: some View {
        HStack {
            Capsule()
                .fill(deployment.status.color.gradient)
                .frame(width: 5, height: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                CoolifyDeploymentCardStatus(deployment.status)
                
                if let commit = deployment.commitMessage, !commit.isEmpty {
                    Text(commit)
                        .lineLimit(2)
                        .footnote()
                        .secondary()
                }
                
                if let created = deployment.createdAt {
                    Text(created)
                        .footnote()
                        .secondary()
                }
            }
        }
#if DEBUG
        .contextMenu {
            Button("Print", systemImage: "hammer") {
                print(deployment)
            }
        }
#endif
    }
}

//#Preview {
//    List {
//        CoolifyDeploymentCard()
//    }
//    .darkSchemePreferred()
//}
