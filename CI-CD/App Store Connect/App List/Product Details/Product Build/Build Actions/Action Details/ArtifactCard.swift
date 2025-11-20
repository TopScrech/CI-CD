import ScrechKit
import AppStoreConnect_Swift_SDK

struct ArtifactCard: View {
    private let artifact: CiArtifact
    
    init(_ artifact: CiArtifact) {
        self.artifact = artifact
    }
    
    private var icon: String? {
        switch artifact.attributes?.fileType {
        case .archive, .archiveExport, .stapledNotarizedArchive: "archivebox"
        case .logBundle: "text.document"
        case .resultBundle, .xcodebuildProducts, .testProducts: "zipper.page"
        case nil: "questionmark"
        }
    }
    
    private var downloadUrl: String? {
        artifact.attributes?.downloadURL?.description
    }
    
    @State private var safariCover = false
    
    var body: some View {
        HStack {
            if let icon {
                Image(systemName: icon)
            }
            
            Text(artifact.attributes?.fileName ?? "-")
            
            Spacer()
            
            if let size = artifact.attributes?.fileSize {
                Text(formatBytes(size))
                    .secondary()
            }
            
            SFButton("arrow.down.circle") {
                safariCover = true
            }
        }
        .safariCover($safariCover, url: downloadUrl ?? "https://bisquit.host/404")
#if DEBUG
        .contextMenu {
            Button {
                Pasteboard.copy(artifact.id)
            } label: {
                Text("Copy artifact id")
                
                Text(artifact.id)
                
                Image(systemName: "document.on.document")
            }
            
            if let downloadUrl {
                Button {
                    Pasteboard.copy(downloadUrl)
                } label: {
                    Text("Copy download url")
                    
                    Text(downloadUrl)
                    
                    Image(systemName: "document.on.document")
                }
            }
        }
#endif
    }
}

#Preview {
    List {
        ArtifactCard(CiArtifact.preview)
        ArtifactCard(CiArtifact.preview)
        ArtifactCard(CiArtifact.preview)
        ArtifactCard(CiArtifact.preview)
        ArtifactCard(CiArtifact.preview)
    }
    .darkSchemePreferred()
}
