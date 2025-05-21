import SwiftUI
import AppStoreConnect_Swift_SDK
import Kingfisher

struct BuildCommitDetails: View {
    @Environment(\.openURL) private var openUrl
    
    private let build: CiBuildRun
    
    init(_ build: CiBuildRun) {
        self.build = build
    }
    
    private let imgSize = 32.0
    
    var body: some View {
        let commit = build.attributes?.sourceCommit
        let author = commit?.author
        
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
                        .semibold()
                    
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
                    .monospaced()
            }
            
            if let commit, let url = commit.webURL {
                Button {
                    openUrl(url)
                } label: {
                    Label("Open on GitHub", systemImage: "link")
                }
                
                ShareLink(item: url)
            }
        }
    }
}

//#Preview {
//    BuildCommitDetails()
//}
