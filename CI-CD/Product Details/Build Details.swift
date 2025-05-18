import ScrechKit
import AppStoreConnect_Swift_SDK

struct BuildDetails: View {
    private let build: CiBuildRun
    
    init(_ build: CiBuildRun) {
        self.build = build
    }
    
    var body: some View {
        List {
            Section {
                if let startedReason = build.attributes?.startReason {
                    ListParam("Reason", param: startedReason.rawValue.lowercased().capitalized)
                }
                
                if let created = build.attributes?.createdDate {
                    HStack {
                        Text("Created")
                        
                        Spacer()
                        
                        Text(created, format: .dateTime)
                    }
                }
                
                if let started = build.attributes?.startedDate {
                    HStack {
                        Text("Started")
                        
                        Spacer()
                        
                        Text(started, format: .dateTime)
                    }
                }
                
                if let finished = build.attributes?.finishedDate {
                    HStack {
                        Text("Finished")
                        
                        Spacer()
                        
                        Text(finished, format: .dateTime)
                    }
                }
            }
            
            Section {
                
            }
        }
    }
}

#Preview {
    BuildDetails(CiBuildRun.preview)
        .darkSchemePreferred()
}
