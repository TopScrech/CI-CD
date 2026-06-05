import ScrechKit

#if canImport(Appearance)
import Appearance
#endif

struct GeneralSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Section {
#if canImport(Appearance)
            AppearancePicker($store.appearance)
#endif
            Button("Change language", systemImage: "globe") {
                openSettings()
            }
            .foregroundStyle(.foreground)
        }
    }
}

#Preview {
    List {
        GeneralSettings()
    }
}
