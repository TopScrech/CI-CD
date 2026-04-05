import SwiftUI

struct DemoSettingsSection: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Section {
            connectDemoRow()
            coolifyDemoRow()
        }
    }
    
    private func connectDemoRow() -> some View {
        Toggle(isOn: $store.connectDemoMode) {
            Label("Connect demo", systemImage: "hammer")
        }
    }
    
    private func coolifyDemoRow() -> some View {
        Toggle(isOn: $store.coolifyDemoMode) {
            Label("Coolify demo", systemImage: "cloud")
        }
    }
    
}
