import Foundation
import OSLog
import AppStoreConnect_Swift_SDK

@Observable
final class AppListVM {
    var products: [CiProduct] = []
    private(set) var availableAppIDs: Set<String>?
    private var fetchID = UUID()
    @ObservationIgnored private var appViewModels: [String: AppVM] = [:]

    func appViewModel(for productID: String) -> AppVM {
        if let vm = appViewModels[productID] {
            return vm
        }

        let vm = AppVM()
        appViewModels[productID] = vm
        return vm
    }

    func visibleProducts(hidingRemovedApps: Bool) -> [CiProduct] {
        guard hidingRemovedApps, let availableAppIDs else {
            return products
        }

        return products.filter {
            guard $0.attributes?.productType == .app,
                  let appID = $0.relationships?.app?.data?.id else {
                return true
            }

            return availableAppIDs.contains(appID)
        }
    }
    
    func fetchProducts(store: ValueStore) async throws {
        let requestID = UUID()
        fetchID = requestID
        availableAppIDs = nil
        let accountID = store.connectAccount?.id
        if let cachedProducts = UserDefaults().loadProducts() {
            products = cachedProducts
        }
        
        guard let provider = try await provider(store: store) else {
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
            var fetchedProducts: [CiProduct] = []
            for try await page in provider.paged(request) {
                fetchedProducts.append(contentsOf: page.data)
            }

            guard fetchID == requestID, store.connectAccount?.id == accountID, !store.connectDemoMode else {
                return
            }

            products = fetchedProducts
            UserDefaults().saveProducts(products)
        } catch {
            Logger().error("Failed to fetch products: \(error)")
        }

        do {
            var appIDs: Set<String> = []
            let appsRequest = APIEndpoint.v1.apps.get(parameters: .init(fieldsApps: [.name], limit: 200))
            for try await page in provider.paged(appsRequest) {
                appIDs.formUnion(page.data.map(\.id))
            }

            guard fetchID == requestID, store.connectAccount?.id == accountID, !store.connectDemoMode else {
                return
            }

            // Only filter after every page succeeds; an incomplete list could hide active apps
            availableAppIDs = appIDs
        } catch {
            Logger().error("Failed to fetch available apps: \(error)")
        }
    }
}
