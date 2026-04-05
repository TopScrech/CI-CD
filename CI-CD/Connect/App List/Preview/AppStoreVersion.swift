import Foundation
import AppStoreConnect_Swift_SDK

extension AppStoreVersion {
    static var preview: AppStoreVersion {
        let attributes = Attributes(
            platform: .ios,
            versionString: "1.0.0",
            appStoreState: .readyForSale,
            appVersionState: .accepted,
            copyright: "© 2025 Example Corp",
            reviewType: .appStore,
            releaseType: .manual,
            earliestReleaseDate: Date(),
            isDownloadable: true,
            createdDate: Date()
        )
        
        let appData = Relationships.App.Data(type: .apps, id: "123456789")
        let app = Relationships.App(data: appData)
        
        let relationships = Relationships(app: app)
        
        return AppStoreVersion(
            type: .appStoreVersions,
            id: "preview-id",
            attributes: attributes,
            relationships: relationships,
            links: nil
        )
    }
}
