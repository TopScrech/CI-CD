import SwiftUI
import AppStoreConnect_Swift_SDK

struct WorkflowActionCard: View {
    private let action: CiAction
    
    init(_ action: CiAction) {
        self.action = action
    }
    
    var body: some View {
        HStack {
            Spacer()
                .frame(width: 16)
            
            if let type = action.actionType {
                Group {
                    switch type {
                    case .analyze:
                        Image(systemName: "magnifyingglass")
                        
                    case .archive:
                        Image(systemName: "archivebox")
                        
                    case .build:
                        Image(systemName: "hammer")
                        
                    case .test:
                        Image(systemName: "checkmark.seal")
                    }
                }
                .title3()
                .secondary()
                .frame(width: 30)
            }
            
            VStack(alignment: .leading) {
                Text(action.name ?? "-")
                
                if let scheme = action.scheme, !scheme.isEmpty {
                    Text(scheme)
                        .secondary()
                }
            }
        }
        .footnote()
    }
}

//#Preview {
//    List {
//        WorkflowActionCard(CiAction.preview)
//    }
//    .darkSchemePreferred()
//}
