import ScrechKit

#if canImport(SafariCover)
import SafariCover
#endif

@main
struct CDApp: App {
    var body: some Scene {
        WindowGroup {
            AppContainer()
        }
    }
}
