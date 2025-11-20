struct CoolifyDatabase: Identifiable, Codable {
    /// Use whichever identifier Coolify exposes; prefer UUID but fall back to numeric id
    var id: String {
        uuid ?? String(rawId ?? environmentId)
    }
    
    let rawId: Int?
    let uuid: String?
    let environmentId: Int
    let name: String
    let description: String?
    
    /// Helps to link databases to their parent project environment for display
    var environmentName: String?
    
    private enum CodingKeys: String, CodingKey {
        case rawId = "id",
             uuid, environmentId, name, description
    }
}
