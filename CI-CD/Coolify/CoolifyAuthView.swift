import SwiftUI

struct CoolifyAuthView: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.dismiss) private var dismiss
    
    private let onDismiss: () async -> Void
    
    init(onDismiss: @escaping () async -> Void = {}) {
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        List {
            if !store.coolifyDemoMode {
                Section("Domain") {
                    TextField("https://coolify.example.com", text: $store.coolifyDomain)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                }
                
                Section("API key") {
                    TextField("welkfp22324o423mkl2lk31", text: $store.coolifyAPIKey)
                        .autocorrectionDisabled()
                }
            }
            
            Section {
                Toggle("Coolify demo", isOn: $store.coolifyDemoMode)
                
                Button("Reset Coolify credentials", role: .destructive, action: resetCredentials)
                
                Button("Save", action: save)
            }
        }
        .animation(.default, value: store.coolifyDemoMode)
    }
    
    private func save() {
        Task {
            await onDismiss()
        }
        
        dismiss()
    }
    
    private func resetCredentials() {
        store.coolifyDomain = "https://coolify.example.com"
        store.coolifyAPIKey = ""
    }
}

#Preview {
    CoolifyAuthView()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
