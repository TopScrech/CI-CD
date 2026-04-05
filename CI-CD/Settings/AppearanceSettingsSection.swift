import SwiftUI
#if canImport(Appearance)
import Appearance
#endif

struct AppearanceSettingsSection: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
#if canImport(Appearance)
        Section {
            AppearancePicker($store.appearance)
        }
#endif
    }
}

#Preview {
    List {
        AppearanceSettingsSection()
    }
}
