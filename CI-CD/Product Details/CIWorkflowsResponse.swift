import Foundation

struct CIWorkflowsResponse: Decodable {
    let data: [CIWorkflow]
    let links: Links
    let meta: Meta
}

struct CIWorkflow: Decodable {
    let type: String
    let id: String
    let attributes: CIWorkflowAttributes
    let relationships: CIWorkflowRelationships
    let links: Links
}

struct CIWorkflowAttributes: Decodable {
    let manualTagStartCondition: String?
    let isLockedForEditing: Bool
    let tagStartCondition: String?
    let lastModifiedDate: String
    let manualPullRequestStartCondition: String?
    let description: String
    let clean: Bool
    let branchStartCondition: BranchStartCondition?
    let containerFilePath: String
    let pullRequestStartCondition: String?
    let scheduledStartCondition: String?
    let isEnabled: Bool
    let name: String
    let manualBranchStartCondition: String?
    let actions: [CIWorkflowAction]
}

struct BranchStartCondition: Decodable {
    let source: BranchSource
    let filesAndFoldersRule: String?
    let autoCancel: Bool
}

struct BranchSource: Decodable {
    let isAllMatch: Bool
    let patterns: [Pattern]
}

struct Pattern: Decodable {
    // If you know the keys, add them here. For now, leave empty.
}

struct CIWorkflowAction: Decodable {
    let name: String
    let actionType: String
    let destination: String?
    let buildDistributionAudience: String?
    let testConfiguration: String?
    let scheme: String
    let platform: String
    let isRequiredToPass: Bool
}

struct CIWorkflowRelationships: Decodable {
    let repository: RelationshipLinks
    let buildRuns: RelationshipLinks
}

struct RelationshipLinks: Decodable {
    let links: RelatedLinks
}

struct RelatedLinks: Decodable {
    let selfLink: String
    let related: String

    private enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case related
    }
}

struct Links: Decodable {
    let selfLink: String

    private enum CodingKeys: String, CodingKey {
        case selfLink = "self"
    }
}

struct Meta: Decodable {
    let paging: Paging
}

struct Paging: Decodable {
    let limit: Int
}
