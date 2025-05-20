import Foundation
import AppStoreConnect_Swift_SDK

@Observable
final class AppListVM {
    var products: [CiProduct] = []
    
    func fetchProducts() async throws {
        guard let provider = try await provider() else {
            return
        }
        
        let request = APIEndpoint
            .v1
            .ciProducts
            .get(parameters: .init(
                //                    sort: [.name],
                fieldsApps: [.ciProduct], include: [.bundleID]
            ))
        
        do {
            products = try await provider.request(request).data
        } catch {
            print(error)
        }
    }
}
