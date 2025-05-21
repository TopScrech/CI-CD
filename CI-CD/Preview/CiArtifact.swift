import Foundation
import AppStoreConnect_Swift_SDK

extension CiArtifact {
    public static var preview: CiArtifact {
        CiArtifact(
            type: .ciArtifacts,
            id: "artifact-123",
            attributes: .init(
                fileType: .archive,
                fileName: "AppArchive.xcarchive",
                fileSize: 42_000_000,
                downloadURL: URL(string: "https://example.com/download/AppArchive.xcarchive")
            ),
            links: ResourceLinks(
                this: "https://api.appstoreconnect.apple.com/v1/ciArtifacts/artifact-123"
            )
        )
    }
}
