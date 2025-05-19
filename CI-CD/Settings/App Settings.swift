import SwiftUI

struct AppSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
#if DEBUG
            Section {
                Button("Deauthorize") {
                    store.isAuthorized = false
                }
            }
#endif
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    AppSettings()
        .environmentObject(ValueStore())
}
