import Foundation
import AppStoreConnect_Swift_SDK

extension UserDefaults {
    func saveProducts(_ servers: [CiProduct]) {
        let encoder = JSONEncoder()
        
        if let data = try? encoder.encode(servers) {
            set(data, forKey: "products")
        }
    }
    
    func loadProducts() -> [CiProduct]? {
        guard let data = data(forKey: "products") else {
            return nil
        }
        
        let decoder = JSONDecoder()
        return try? decoder.decode([CiProduct].self, from: data)
    }
}
