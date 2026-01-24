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
            
            Button("Save", action: save)
        }
    }
    
    private func save() {
        Task {
            await onDismiss()
        }
        
        dismiss()
    }
}

#Preview {
    CoolifyAuthView()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
