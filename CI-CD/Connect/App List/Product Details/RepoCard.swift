import ScrechKit
import AppStoreConnect_Swift_SDK

struct RepoCard: View {
    @Environment(\.openURL) private var openURL
    
    private let repo: ScmRepository
    
    init(_ repo: ScmRepository) {
        self.repo = repo
    }
    
    private var stringURL: String? {
        repo.attributes?.httpCloneURL?.description
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(repo.attributes?.repositoryName ?? "-")
                .title3()
            
            Text(repo.attributes?.ownerName ?? "-")
                .secondary()
            
            if let stringURL {
                Text(stringURL)
                    .footnote()
                    .tertiary()
            }
        }
        .contextMenu {
            if let url = URL(string: stringURL ?? "") {
                Section {
                    Button("Open on GitHub", systemImage: "link") {
                        openURL(url)
                    }
                }
                
                Button("Copy repository url", systemImage: "doc.on.doc") {
                    Pasteboard.copy(url)
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
