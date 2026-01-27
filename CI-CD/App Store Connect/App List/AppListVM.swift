import Foundation
import OSLog
import AppStoreConnect_Swift_SDK

@Observable
final class AppListVM {
    var products: [CiProduct] = []
    
    func fetchProducts() async throws {
        if let cachedProducts = UserDefaults().loadProducts() {
            products = cachedProducts
        }
        
        guard let provider = try await provider() else {
            return
        }
        
        let request = APIEndpoint
            .v1
            .ciProducts
            .get(parameters: .init(
                fieldsApps: [.ciProduct],
                include: [.bundleID, .app]
            ))
        
        do {
            products = try await provider.request(request).data
            UserDefaults().saveProducts(products)
        } catch {
            Logger().error("Failed to fetch products: \(error)")
        }
    }
}
