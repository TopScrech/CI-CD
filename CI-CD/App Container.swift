import SwiftUI

struct AppContainer: View {
    @StateObject private var store = ValueStore()
    
    var body: some View {
        NavigationStack {
            if store.isAuthorized {
                AppListView()
            } else {
                AuthView()
            }
        }
        .environmentObject(store)
        .preferredColorScheme(store.appearance.scheme)
    }
}

#Preview {
    AppContainer()
}
