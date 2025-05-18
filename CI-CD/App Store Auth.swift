import Foundation
import SwiftJWT

struct AppStoreAuth {
    private static let keyID = "3U3CPFA54N"
    private static let issuerID = "74c48f6b-b4a9-409a-8ed2-44d24a13d1c7"
    private static let audience = "appstoreconnect-v1"
    
    static func fetchApps() async throws -> Data? {
        let subdir = "/v1/ciProducts"
        let urlString = "https://api.appstoreconnect.apple.com" + subdir
        
        let jwt = try generateJWT(subdir)
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code:", httpResponse.statusCode)
                print("Response Headers:", httpResponse.allHeaderFields)
                
                if httpResponse.statusCode != 200 {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response"
                    print("Server Response:", responseString)
                    
                    throw URLError(.badServerResponse)
                }
            } else {
                print("Error: no response")
            }
            
            return data
        } catch {
            print("Error:", error)
        }
        
        return nil
    }
    
    private static func generateJWT(_ url: String) throws -> String {
        struct AppStorePayload: Claims {
            let iss, aud: String
            let iat, exp: Int
            let scope: [String]
        }
        
        let privateKeyData = try loadPrivateKey()
        
        let now = Int(Date().timeIntervalSince1970)
        
        let claims = AppStorePayload(
            iss: issuerID,
            aud: audience,
            iat: now,
            exp: now + 60,
            scope: [
                "GET " + url,
            ]
        )
        
        let header = Header(kid: keyID)
        
        var jwt = JWT(header: header, claims: claims)
        let jwtSigner = JWTSigner.es256(privateKey: privateKeyData)
        
        return try jwt.sign(using: jwtSigner)
    }
    
    private static func loadPrivateKey() throws -> Data {
        guard let keyUrl = Bundle.main.url(forResource: "AuthKey_\(keyID)", withExtension: "p8") else {
            throw URLError(.fileDoesNotExist)
        }
        
        print("Key found")
        
        return try Data(contentsOf: keyUrl)
    }
}
