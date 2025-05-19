import ScrechKit
import AppStoreConnect_Swift_SDK
import Kingfisher

struct BuildDetails: View {
    @Environment(\.openURL) private var openUrl
    
    //    @State private var vm = BuildVM()
    
    private let build: CiBuildRun
    
    init(_ build: CiBuildRun) {
        self.build = build
    }
    
    private let imgSize = 32.0
    
    var body: some View {
        let commit = build.attributes?.sourceCommit
        let author = commit?.author
        
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
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        if let avatar = author?.avatarURL {
                            KFImage(avatar)
                                .resizable()
                                .frame(imgSize)
                                .clipShape(.circle)
                        }
                        
                        Text(author?.displayName ?? "-")
                        
                        Spacer()
                        
                        if let commit, let id = commit.commitSha?.prefix(7) {
                            Text(id)
                                .secondary()
                                .padding(.vertical, 2)
                                .padding(.horizontal, 8)
                                .background(.ultraThinMaterial, in: .capsule)
                        }
                    }
                    
                    Text(commit?.message ?? "-")
                }
                
                if let commit, let url = commit.webURL {
                    Button {
                        openUrl(url)
                    } label: {
                        Label("Open on GitHub", systemImage: "link")
                    }
                }
            }
            
            //            Section {
            //                Text(build.attributes?.)
            //            }
        }
    }
}

#Preview {
    BuildDetails(CiBuildRun.preview)
        .darkSchemePreferred()
}
