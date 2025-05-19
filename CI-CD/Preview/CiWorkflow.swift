import Foundation
import AppStoreConnect_Swift_SDK

extension CiWorkflow {
    public static var preview: CiWorkflow {
        CiWorkflow(
            type: .ciWorkflows,
            id: "workflow-1",
            attributes: .init(
                name: "Build & Test",
                description: "A workflow that builds and tests the app.",
                branchStartCondition: nil,
                tagStartCondition: nil,
                pullRequestStartCondition: nil,
                scheduledStartCondition: nil,
                manualBranchStartCondition: nil,
                manualTagStartCondition: nil,
                manualPullRequestStartCondition: nil,
                actions: [],
                isEnabled: true,
                isLockedForEditing: false,
                isClean: true,
                containerFilePath: "/ci/container.yml",
                lastModifiedDate: Date()
            ),
            relationships: .init(
                product: .init(
                    data: .init(type: .ciProducts, id: "product-1")
                ),
                repository: .init(
                    links: nil,
                    data: .init(type: .scmRepositories, id: "repo-1")
                ),
                xcodeVersion: .init(
                    data: .init(type: .ciXcodeVersions, id: "xcode-15")
                ),
                macOsVersion: .init(
                    data: .init(type: .ciMacOsVersions, id: "macos-14")
                ),
                buildRuns: .init(links: nil)
            ),
            links: nil
        )
    }
}
