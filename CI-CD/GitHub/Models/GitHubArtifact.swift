import Foundation

struct GitHubArtifact: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let sizeInBytes: Int
    let url: URL?
    let archiveDownloadURL: URL?
    let expired: Bool
    let createdAt: Date
    let expiresAt: Date?
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name, url, expired
        case sizeInBytes = "size_in_bytes"
        case archiveDownloadURL = "archive_download_url"
        case createdAt = "created_at"
        case expiresAt = "expires_at"
        case updatedAt = "updated_at"
    }
}

struct GitHubArtifactResponse: Codable {
    let totalCount: Int
    let artifacts: [GitHubArtifact]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case artifacts
    }
}
