import Foundation

enum GitHubPreview {
    static let repository = GitHubRepository(
        id: 1,
        name: "ci-cd",
        fullName: "topscrech/ci-cd",
        privateRepository: true,
        htmlURL: URL(string: "https://github.com/topscrech/ci-cd"),
        description: "Build and release automation",
        defaultBranch: "main",
        owner: GitHubRepositoryOwner(login: "topscrech"),
        pushedAt: .now
    )
    
    static let workflow = GitHubWorkflow(
        id: 2,
        name: "iOS",
        path: ".github/workflows/ios.yml",
        state: "active",
        htmlURL: URL(string: "https://github.com/topscrech/ci-cd/actions/workflows/ios.yml"),
        badgeURL: nil
    )
    
    static let workflowRun = GitHubWorkflowRun(
        id: 3,
        name: "iOS",
        displayTitle: "Build and test",
        status: "completed",
        conclusion: "success",
        event: "push",
        headBranch: "main",
        headSha: "abc123def456",
        htmlURL: URL(string: "https://github.com/topscrech/ci-cd/actions/runs/3"),
        createdAt: .now,
        updatedAt: .now,
        runStartedAt: .now,
        actor: GitHubActor(login: "topscrech")
    )
}
