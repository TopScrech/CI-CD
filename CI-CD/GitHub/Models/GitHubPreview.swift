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
    
    static let job = GitHubWorkflowJob(
        id: 4,
        runID: 3,
        name: "Build",
        status: "completed",
        conclusion: "success",
        startedAt: .now,
        completedAt: .now,
        htmlURL: URL(string: "https://github.com/topscrech/ci-cd/actions/runs/3/job/4"),
        steps: [
            GitHubWorkflowStep(
                name: "Checkout",
                status: "completed",
                conclusion: "success",
                number: 1,
                startedAt: .now,
                completedAt: .now
            )
        ]
    )
    
    static let artifact = GitHubArtifact(
        id: 5,
        name: "Build Logs",
        sizeInBytes: 24_576,
        url: URL(string: "https://api.github.com/repos/topscrech/ci-cd/actions/artifacts/5"),
        archiveDownloadURL: URL(string: "https://api.github.com/repos/topscrech/ci-cd/actions/artifacts/5/zip"),
        expired: false,
        createdAt: .now,
        expiresAt: .now,
        updatedAt: .now
    )
}
