import SwiftUI

struct AppContainer: View {
    @StateObject private var store = ValueStore()
    
    var body: some View {
        NavigationStack {
            if store.isAuthorized {
                HomeView()
            } else {
                AuthView()
            }
        }
#if os(iOS)
        .statusBarHidden(!store.showStatusBar)
#endif
        .environmentObject(store)
#if canImport(Appearance)
        .preferredColorScheme(store.appearance.scheme)
#endif
    }
}

#Preview {
    AppContainer()
        .darkSchemePreferred()
}
