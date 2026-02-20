import SwiftData

enum PreviewModelContainer {
    static let inMemory: ModelContainer = {
        let schema = Schema([
            ProviderAccount.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        return try! ModelContainer(for: schema, configurations: configuration)
    }()
}
