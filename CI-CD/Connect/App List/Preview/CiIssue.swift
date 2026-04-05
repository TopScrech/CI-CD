import Foundation
import AppStoreConnect_Swift_SDK

extension CiIssue {
    public static var preview: CiIssue {
        CiIssue(
            type: .ciIssues,
            id: "1234567890",
            attributes: .init(
                issueType: .error,
                message: "This is a sample error message for preview",
                fileSource: FileLocation(
                    path: "/Users/example/Project/File.swift",
                    lineNumber: 42
                ),
                category: "Build"
            ),
            links: ResourceLinks(
                this: "https://api.appstoreconnect.apple.com/v1/ciIssues/1234567890"
            )
        )
    }
}

