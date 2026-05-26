import ScrechKit
import SwiftData

struct DebugSettings: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.modelContext) private var modelContext
    
    @State private var sheetAuthConnect = false
    @State private var sheetAuthCoolify = false
    @State private var sheetAuthGitHub = false
    
    var body: some View {
        List {
            Section {
#if os(iOS)
                Toggle("Status bar", isOn: $store.showStatusBar)
#endif
            }
        }
        .navigationTitle("Debug")
    }
}

#Preview {
    List {
        DebugSettings()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
    .modelContainer(PreviewModelContainer.inMemory)
}
