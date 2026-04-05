import Foundation
import AppStoreConnect_Swift_SDK

extension CiProduct {
    public static var preview: CiProduct {
        CiProduct(
            type: .ciProducts,
            id: "12345",
            attributes: .init(
                name: "Sample Product",
                createdDate: Date(),
                productType: .app
            ),
            relationships: .init(
                app: .init(
                    links: nil,
                    data: .init(type: .apps, id: "app-1")
                ),
                bundleID: .init(
                    data: .init(type: .bundleIDs, id: "host.bisquit.Bisquit-host")
                ),
                workflows: .init(links: nil),
                primaryRepositories: .init(
                    links: nil,
                    meta: nil,
                    data: [
                        .init(type: .scmRepositories, id: "repo-1")
                    ]
                ),
                additionalRepositories: .init(links: nil),
                buildRuns: .init(links: nil)
            ),
            links: nil
        )
    }
}
