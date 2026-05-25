import ScrechKit

struct GitHubArtifactRow: View {
    private let artifact: GitHubArtifact
    
    init(_ artifact: GitHubArtifact) {
        self.artifact = artifact
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(artifact.name)
                    .headline()
                
                Spacer()
                
                if artifact.expired {
                    Text("Expired")
                        .caption()
                        .secondary()
                }
            }
            
            LabeledContent("Size", value: artifact.sizeInBytes.formatted(.byteCount(style: .file)))
            
            if let expiresAt = artifact.expiresAt {
                LabeledContent("Expires") {
                    Text(expiresAt, format: .dateTime)
                }
            }
        }
        .contextMenu {
            if let url = artifact.archiveDownloadURL {
                Link(destination: url) {
                    Label("Download", systemImage: "arrow.down.circle")
                }
            }
        }
    }
}

#Preview {
    List {
        GitHubArtifactRow(GitHubPreview.artifact)
    }
    .darkSchemePreferred()
}
