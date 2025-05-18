struct CIBuildRunsResponse: Decodable {
    let data: [CIBuildRun]
    let links: CILinks
    let meta: CIMeta
}

struct CIBuildRun: Identifiable, Decodable {
    let id: String
    let type: String
    let attributes: CIBuildRunAttributes
    let relationships: CIBuildRunRelationships
    let links: CILinks
}

struct CIBuildRunAttributes: Decodable {
    let number: Int
    let createdDate: String
    let startedDate: String?
    let finishedDate: String?
    let sourceCommit: CICommit
    let destinationCommit: CICommit?
    let isPullRequestBuild: Bool
    let issueCounts: CIIssueCounts?
    let executionProgress: String
    let completionStatus: String?
    let startReason: String
    let cancelReason: String?
}

struct CICommit: Decodable {
    var id: String {
        String(commitSha.prefix(7))
    }
    
    let commitSha: String
    let message: String
    let author: CIAuthor
    let committer: CIAuthor
    let webUrl: String
}

struct CIAuthor: Decodable {
    let displayName: String
    let avatarUrl: String
}

struct CIIssueCounts: Decodable {}

struct CIBuildRunRelationships: Decodable {
    let builds: CIBuildRunRelationshipLinks
    let actions: CIBuildRunRelationshipLinks
}

struct CIBuildRunRelationshipLinks: Decodable {
    let links: CILinks
}

struct CILinks: Decodable {
    let selfLink: String
    let related: String?

    private enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case related
    }
}

struct CIMeta: Decodable {
    let paging: CIPaging
}

struct CIPaging: Decodable {
    let limit: Int
}

extension CIBuildRun {
    static let preview = CIBuildRun(
        id: "buildrun-123",
        type: "buildRuns",
        attributes: CIBuildRunAttributes(
            number: 42,
            createdDate: "2024-05-18T12:34:56Z",
            startedDate: "2024-05-18T12:35:00Z",
            finishedDate: "2024-05-18T12:45:00Z",
            sourceCommit: CICommit(
                commitSha: "abcdef1234567890",
                message: "Fix critical bug",
                author: CIAuthor(
                    displayName: "Jane Doe",
                    avatarUrl: "https://avatars.githubusercontent.com/u/89252798?s=96&v=4"
                ),
                committer: CIAuthor(
                    displayName: "John Smith",
                    avatarUrl: "https://avatars.githubusercontent.com/u/89252798?s=96&v=4"
                ),
                webUrl: "https://github.com/example/repo/commit/abcdef1234567890"
            ),
            destinationCommit: CICommit(
                commitSha: "fedcba0987654321",
                message: "Merge branch 'feature'",
                author: CIAuthor(
                    displayName: "Alice Example",
                    avatarUrl: "https://example.com/avatar/alice.png"
                ),
                committer: CIAuthor(
                    displayName: "Bob Example",
                    avatarUrl: "https://example.com/avatar/bob.png"
                ),
                webUrl: "https://github.com/example/repo/commit/fedcba0987654321"
            ),
            isPullRequestBuild: true,
            issueCounts: nil, // or CIIssueCounts() if you want to provide an empty instance
            executionProgress: "completed",
            completionStatus: "SUCCEEDED",
            startReason: "commit",
            cancelReason: nil
        ),
        relationships: CIBuildRunRelationships(
            builds: CIBuildRunRelationshipLinks(
                links: CILinks(
                    selfLink: "https://api.example.com/builds/123",
                    related: "https://api.example.com/builds/related"
                )
            ),
            actions: CIBuildRunRelationshipLinks(
                links: CILinks(
                    selfLink: "https://api.example.com/actions/123",
                    related: nil
                )
            )
        ),
        links: CILinks(
            selfLink: "https://api.example.com/buildRuns/123",
            related: nil
        )
    )
}
