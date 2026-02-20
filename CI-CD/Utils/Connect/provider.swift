import Foundation
import AppStoreConnect_Swift_SDK

func provider(store: ValueStore) async throws -> APIProvider? {
    guard !store.connectDemoMode else {
        return nil
    }

    guard let account = store.connectAccount, account.isAuthorized else {
        return nil
    }

    let configuration = try APIConfiguration(
        issuerID: account.issuerID,
        privateKeyID: account.privateKeyID,
        privateKey: account.privateKey
    )

    return APIProvider(configuration: configuration)
}
