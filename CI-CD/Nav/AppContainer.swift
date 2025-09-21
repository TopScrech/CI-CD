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
        .environmentObject(store)
#if os(iOS)
        .preferredColorScheme(store.appearance.scheme)
#endif
    }
}

#Preview {
    AppContainer()
        .darkSchemePreferred()
}
