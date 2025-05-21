struct Welcome: Codable {
    let resultCount: Int
    let results: [Result]
}

struct Result: Codable {
    let artworkUrl512, trackViewUrl: String
}
