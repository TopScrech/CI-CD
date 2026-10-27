import ScrechKit
import ASC

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
    
    private var downloadURL: String? {
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
        .safariCover($safariCover, url: downloadURL ?? "https://bisquit.host/404")
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
