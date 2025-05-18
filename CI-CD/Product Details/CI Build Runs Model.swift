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
    let startedDate: String
    let finishedDate: String
    let sourceCommit: CICommit
    let destinationCommit: CICommit?
    let isPullRequestBuild: Bool
    let issueCounts: CIIssueCounts?
    let executionProgress: String
    let completionStatus: String
    let startReason: String
    let cancelReason: String?
}

struct CICommit: Decodable {
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
