import Foundation

// https://api.appstoreconnect.apple.com/v1/ciProducts

struct CIProdutcs: Decodable {
    let data: [CIProduct]
}

struct CIProduct: Identifiable, Decodable {
    let id: String
    let data: [CIProduct]
    let attributes: CIProductAttributes
}

struct CIProductAttributes: Decodable {
    let name, productType: String
    let createdDate: Date
}
