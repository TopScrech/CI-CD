import ScrechKit

struct PanelSidebarCustomizationSheet: View {
    @Environment(PanelSidebarCustomizationVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section("Sidebar") {
                Picker("Position", selection: $vm.placement) {
                    ForEach(PanelSidebarPlacement.allCases, id: \.self) { placement in
                        Label(placement.title, systemImage: placement.icon)
                            .tag(placement)
                    }
                }
                .pickerStyle(.segmented)
            }
            
        }
        .navigationTitle("Customization")
        .scrollIndicators(.never)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Reset", action: vm.reset)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PanelSidebarCustomizationSheet()
            .environment(PanelSidebarCustomizationVM())
    }
    .darkSchemePreferred()
}
