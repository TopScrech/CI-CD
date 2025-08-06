import ScrechKit
import AppStoreConnect_Swift_SDK

struct RepoCard: View {
    @Environment(\.openURL) private var openUrl
    
    private let repo: ScmRepository
    
    init(_ repo: ScmRepository) {
        self.repo = repo
    }
    
    private var stringUrl: String? {
        repo.attributes?.httpCloneURL?.description
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(repo.attributes?.repositoryName ?? "-")
                .title3()
            
            Text(repo.attributes?.ownerName ?? "-")
                .secondary()
            
            if let stringUrl {
                Text(stringUrl)
                    .footnote()
                    .tertiary()
            }
        }
        .contextMenu {
            if let url = URL(string: stringUrl ?? "") {
                Section {
                    Button {
                        openUrl(url)
                    } label: {
                        Label("Open on GitHub", systemImage: "link")
                    }
                }
                
                Button {
                    Pasteboard.copy(url)
                } label: {
                    Label("Copy repository url", systemImage: "doc.on.doc")
                }
                
                ShareLink(item: url)
            }
        }
    }
}

#Preview {
    List {
        RepoCard(ScmRepository.preview)
    }
    .darkSchemePreferred()
}
