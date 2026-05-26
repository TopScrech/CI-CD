import SwiftUI

struct GitHubArtifactList: View {
    let artifacts: [GitHubArtifact]
    let errorMessage: String?
    
    var body: some View {
        List {
            if let errorMessage {
                ContentUnavailableView("GitHub error", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
            }
            
            ForEach(artifacts) {
                GitHubArtifactRow($0)
            }
        }
        .overlay {
            if artifacts.isEmpty && errorMessage == nil {
                ContentUnavailableView("No artifacts found", systemImage: "archivebox")
            }
        }
    }
}

#Preview {
    GitHubArtifactList(artifacts: [GitHubPreview.artifact], errorMessage: nil)
        .darkSchemePreferred()
}
