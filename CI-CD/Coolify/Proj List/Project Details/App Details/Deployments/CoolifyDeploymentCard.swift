import OSLog
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
                .frame(width: 5, height: 90)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    CoolifyDeploymentCardStatus(deployment.status)
                    
                    Spacer()
                    
                    if let finishedAgoText = deployment.finishedAgoText {
                        Text(finishedAgoText)
                            .secondary()
                    }
                }
                
                if let commit = deployment.commitMessage, !commit.isEmpty {
                    Text(commit)
                        .lineLimit(2)
                        .footnote()
                        .secondary()
                }
                
                if let createdAtText = deployment.createdAtText {
                    Text("Started \(createdAtText)")
                        .footnote()
                        .secondary()
                }
                
                if let durationText = deployment.durationText {
                    Text("Duration \(durationText)")
                        .footnote()
                        .secondary()
                }
                
                if let finishedDateText = deployment.finishedDateText {
                    Text("Finished \(finishedDateText)")
                        .footnote()
                        .secondary()
                }
            }
        }
#if DEBUG
        .contextMenu {
            Button("Print", systemImage: "hammer") {
                Logger().info("Deployment: \(String(describing: deployment))")
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
