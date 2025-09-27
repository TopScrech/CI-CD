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
        .statusBarHidden(!store.showStatusBar)
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
