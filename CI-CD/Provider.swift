import Foundation
import AppStoreConnect_Swift_SDK

func provider() async throws -> APIProvider? {
    guard let keyUrl = Bundle.main.url(forResource: "AuthKey_3U3CPFA54N", withExtension: "p8") else {
        print("Key URL not found")
        return nil
    }
    
    let configuration = try APIConfiguration(issuerID: "74c48f6b-b4a9-409a-8ed2-44d24a13d1c7", privateKeyID: "3U3CPFA54N", privateKeyURL: keyUrl)
    
    return APIProvider(configuration: configuration)
}
