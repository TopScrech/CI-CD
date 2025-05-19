import Foundation
import AppStoreConnect_Swift_SDK

func provider() async throws -> APIProvider? {
    let configuration = try APIConfiguration(
        issuerID: ValueStore().issuer,
        privateKeyID: ValueStore().privateKeyId,
        privateKey: ValueStore().privateKey
    )
    
    return APIProvider(configuration: configuration)
}
