import Foundation

struct CoolifyProject: Identifiable, Codable {
    let id: Int
    let uuid: String
    let name: String
    let description: String?
    let environments: [CoolifyProjectEnv]?
}

// linked with a different request
struct CoolifyProjectEnv: Identifiable, Codable {
    let id: Int
    let projectId: Int?
    let name: String
    let description: String?
    let createdAt: String?
    let updatedAt: String?
}

//[
//    {
//    "id" : 1,
//    "name" : "Bisquit",
//    "description" : null,
//    "uuid" : "qoo08kk4gw4cwkwoccssos4o"
//},
//    {
//    "id" : 4,
//    "name" : "TopScrech",
//    "description" : "",
//    "uuid" : "oww4g0ocwgcs84kwk84wgcw4"
//},
//    {
//    "id" : 6,
//    "name" : "BisquitHost Prod",
//    "description" : "",
//    "uuid" : "dg804s0ggcogwwc40cw00wc8"
//},
//    {
//    "id" : 9,
//    "name" : "Endera",
//    "description" : "",
//    "uuid" : "kswwc08cscs0gggkgkcssc04"
//},
//    {
//    "id" : 10,
//    "description" : "Vapor app",
//    "name" : "Swift-Backends",
//    "uuid" : "r040gws0www8c0ow84cs0g0w"
//}
//]
