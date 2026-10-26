import Foundation

struct GitHubArtifact: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let sizeInBytes: Int
    let archiveDownloadURL: URL?
    let expired: Bool
    let expiresAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name, expired
        case sizeInBytes = "size_in_bytes"
        case archiveDownloadURL = "archive_download_url"
        case expiresAt = "expires_at"
    }
}

struct GitHubArtifactResponse: Codable {
    let artifacts: [GitHubArtifact]
}
