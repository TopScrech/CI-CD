import OSLog
import SwiftData

enum AccountModelContainer {
    static let shared: ModelContainer = {
        let schema = Schema([
            ProviderAccount.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            Logger().fault("Failed to create account model container: \(error)")
            fatalError("Failed to create account model container: \(error)")
        }
    }()
}
