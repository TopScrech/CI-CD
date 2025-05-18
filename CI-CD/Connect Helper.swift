//import Foundation
//import SwiftJWT
//
//struct ConnectHelper {
//    private static let keyID = "3U3CPFA54N"
//    private static let issuerID = "74c48f6b-b4a9-409a-8ed2-44d24a13d1c7"
//    private static let audience = "appstoreconnect-v1"
//    
//    static func generateJWT(_ url: String) throws -> String {
//        struct AppStorePayload: Claims {
//            let iss, aud: String
//            let iat, exp: Int
//            let scope: [String]
//        }
//        
//        let privateKeyData = try loadPrivateKey()
//        
//        let now = Int(Date().timeIntervalSince1970)
//        
//        let claims = AppStorePayload(
//            iss: issuerID,
//            aud: audience,
//            iat: now,
//            exp: now + 60,
//            scope: [
//                "GET " + url,
//            ]
//        )
//        
//        let header = Header(kid: keyID)
//        
//        var jwt = JWT(header: header, claims: claims)
//        let jwtSigner = JWTSigner.es256(privateKey: privateKeyData)
//        
//        return try jwt.sign(using: jwtSigner)
//    }
//    
//    private static func loadPrivateKey() throws -> Data {
//        guard let keyUrl = Bundle.main.url(forResource: "AuthKey_\(keyID)", withExtension: "p8") else {
//            throw URLError(.fileDoesNotExist)
//        }
//        
//        print("Key found")
//        
//        return try Data(contentsOf: keyUrl)
//    }
//}
