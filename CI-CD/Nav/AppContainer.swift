import SwiftUI
import SwiftData

struct AppContainer: View {
    @StateObject private var store = ValueStore()
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            HomeView()
        }
#if os(iOS)
        .statusBarHidden(!store.showStatusBar)
#endif
        .environmentObject(store)
#if canImport(Appearance)
        .preferredColorScheme(store.appearance.scheme)
#endif
        .task(id: modelContext) {
            store.configure(context: modelContext)
        }
    }
}

#Preview {
    AppContainer()
        .darkSchemePreferred()
        .modelContainer(PreviewModelContainer.inMemory)
}
