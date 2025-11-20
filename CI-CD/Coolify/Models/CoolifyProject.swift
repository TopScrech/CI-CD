import Foundation

struct CoolifyProject: Identifiable, Codable {
    let id: Int
    let uuid: String
    let name: String
    let description: String?
        
    // linked with a different request
    let environments: [CoolifyProjectEnv]?
}

//[
//    {
//        "id" : 1,
//        "name" : "Bisquit",
//        "description" : null,
//        "uuid" : "qoo08kk4gw4cwkwoccssos4o"
//    }
//]
