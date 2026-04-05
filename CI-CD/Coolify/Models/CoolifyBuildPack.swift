import Foundation

struct CoolifyBuildPack: Identifiable, Hashable {
    let rawValue: String
    
    var id: String {
        rawValue
    }
    
    var title: String {
        switch rawValue {
        case "nixpacks":
            "Nixpacks"
        case "static":
            "Static"
        case "dockerfile":
            "Dockerfile"
        case "dockercompose":
            "Docker Compose"
        case "dockerimage":
            "Docker Image"
        default:
            rawValue
                .replacing("_", with: " ")
                .split(separator: " ")
                .map(\.capitalized)
                .joined(separator: " ")
        }
    }
}
