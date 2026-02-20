import Foundation
import AppStoreConnect_Swift_SDK

extension CiBuildRun {
    public static var preview: CiBuildRun {
        CiBuildRun(
            type: .ciBuildRuns,
            id: "1234567890",
            attributes: .init(
                number: 42,
                createdDate: Date(),
                startedDate: Date().addingTimeInterval(-3600),
                finishedDate: Date(),
                sourceCommit: .init(
                    commitSha: "abcdef1234567890",
                    message: "Initial commit",
                    author: CiGitUser(
                        displayName: "Jane Doe",
                        avatarURL: "https://avatars.githubusercontent.com/u/89252798?v=4"
                    ),
                    committer: CiGitUser(
                        displayName: "Jane Doe",
                        avatarURL: "https://avatars.githubusercontent.com/u/89252798?v=4"
                    ),
                    webURL: "https://github.com/example/repo/commit/abcdef1234567890"
                ),
                destinationCommit: .init(
                    commitSha: "fedcba0987654321",
                    message: "Merge branch 'feature'",
                    author: CiGitUser(
                        displayName: "Jane Doe",
                        avatarURL: "https://avatars.githubusercontent.com/u/89252798?v=4"
                    ),
                    committer: CiGitUser(
                        displayName: "Jane Doe",
                        avatarURL: "https://avatars.githubusercontent.com/u/89252798?v=4"
                    ),
                    webURL: "https://github.com/example/repo/commit/fedcba0987654321"
                ),
                isPullRequestBuild: true,
                issueCounts: CiIssueCounts(
                    analyzerWarnings: 2,
                    errors: 1,
                    testFailures: 0,
                    warnings: 3
                ),
                executionProgress: .complete,
                completionStatus: .succeeded,
                startReason: .manual,
                cancelReason: nil
            ),
            relationships: .init(
                builds: nil,
                workflow: .init(
                    data: .init(
                        type: .ciWorkflows,
                        id: "workflow-123"
                    )
                ),
                product: .init(
                    data: .init(
                        type: .ciProducts,
                        id: "product-123"
                    )
                ),
                sourceBranchOrTag: .init(
                    data: .init(
                        type: .scmGitReferences,
                        id: "refs/heads/main"
                    )
                ),
                destinationBranch: .init(
                    data: .init(
                        type: .scmGitReferences,
                        id: "refs/heads/develop"
                    )
                ),
                actions: nil,
                pullRequest: .init(
                    data: .init(
                        type: .scmPullRequests,
                        id: "pr-123"
                    )
                )
            ),
            links: nil
        )
    }
}
