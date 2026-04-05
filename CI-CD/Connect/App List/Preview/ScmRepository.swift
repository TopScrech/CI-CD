import Foundation
import AppStoreConnect_Swift_SDK

public extension ScmRepository {
    static var preview: ScmRepository {
        ScmRepository(
            type: .scmRepositories,
            id: "preview-id",
            attributes: .init(
                lastAccessedDate: Date(),
                httpCloneURL: URL(string: "https://github.com/example/repo.git"),
                sshCloneURL: URL(string: "git@github.com:example/repo.git"),
                ownerName: "Bisquit.Owner",
                repositoryName: "example-repo"
            ),
            relationships: .init(
                scmProvider: .init(
                    data: .init(
                        type: .scmProviders,
                        id: "provider-id"
                    )
                ),
                defaultBranch: .init(
                    data: .init(
                        type: .scmGitReferences,
                        id: "main"
                    )
                ),
                gitReferences: .init(
                    links: .init(
                        related: "https://api.example.com/git-references"
                    )
                ),
                pullRequests: .init(
                    links: .init(
                        related: "https://api.example.com/pull-requests"
                    )
                )
            ),
            links: .init(
                this: "https://api.example.com/scm-repositories/preview-id"
            )
        )
    }
}
