import Foundation
import OSLog
import AppStoreConnect_Swift_SDK

@Observable
final class ActionVM {
    private(set) var issues: [CiIssue] = []
    private(set) var artifacts: [CiArtifact] = []
    
    var warningCount: Int? {
        issues.filter {
            $0.attributes?.issueType == .warning
        }.count
    }
    
    var errorCount: Int? {
        issues.filter {
            $0.attributes?.issueType == .error
        }.count
    }
    
    var analyzerWarningCount: Int? {
        issues.filter {
            $0.attributes?.issueType == .analyzerWarning
        }.count
    }
    
    var testFailureCount: Int? {
        issues.filter {
            $0.attributes?.issueType == .testFailure
        }.count
    }
    
    func buildIssues(_ actionId: String) async throws {
        guard let provider = try await provider() else {
            return
        }
        
        let request = APIEndpoint
            .v1
            .ciBuildActions
            .id(actionId)
            .issues
            .get()
        
        do {
            issues = try await provider.request(request).data
        } catch {
            Logger().error("Failed to fetch build issues: \(error.localizedDescription)")
        }
    }
    
    func buildArtifacts(_ actionId: String) async throws {
        guard let provider = try await provider() else {
            return
        }
        
        let request = APIEndpoint
            .v1
            .ciBuildActions
            .id(actionId)
            .artifacts
            .get()
        
        do {
            artifacts = try await provider.request(request).data
        } catch {
            Logger().error("Failed to fetch build artifacts: \(error.localizedDescription)")
        }
    }
}
