import ScrechKit
import SwiftData

#if canImport(SafariCover)
import SafariCover
#endif

@main
struct CDApp: App {
    var body: some Scene {
        WindowGroup {
            AppContainer()
        }
        .modelContainer(AccountModelContainer.shared)
    }
}
