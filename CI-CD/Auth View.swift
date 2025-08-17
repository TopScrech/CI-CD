import SwiftUI
import UniformTypeIdentifiers

struct AuthView: View {
    @EnvironmentObject private var store: ValueStore
    
    @State private var showPicker = false
    
    private var disabled: Bool {
        if store.demoMode {
            false
        } else {
            store.issuer.isEmpty ||
            store.privateKey.isEmpty ||
            store.privateKeyId.isEmpty
        }
    }
    
    var body: some View {
        List {
            if !store.demoMode {
                Section {
                    HStack {
                        TextField("Issuer ID", text: $store.issuer)
                            .autocorrectionDisabled()
#if !os(macOS)
                            .textInputAutocapitalization(.none)
#endif
                        PasteButton(payloadType: String.self) { paste in
                            if let issuer = paste.first, issuer.count == 36 {
                                store.issuer = issuer
                            }
                        }
                    }
                } header: {
                    Text("Issuer ID")
                } footer: {
                    Text("You need an API key with the 'Admin' role from App Store Connect to start builds with external deployments. API keys with the 'Developer' role cannot be used for this")
                }
                
                Section("Private Key") {
                    TextEditor(text: $store.privateKey)
                        .autocorrectionDisabled()
#if !os(macOS)
                        .textInputAutocapitalization(.none)
#endif
                    TextField("Private Key ID", text: $store.privateKeyId)
                        .autocorrectionDisabled()
#if !os(macOS)
                        .textInputAutocapitalization(.none)
#endif
                    Button("Import from Files", systemImage: "document.badge.plus") {
                        showPicker = true
                    }
                    .foregroundStyle(.foreground)
                }
            }
            
            Section {
                Toggle("Demo Mode", isOn: $store.demoMode)
                
                Button("Authorize") {
                    store.isAuthorized = true
                }
                .disabled(disabled)
            }
        }
        .animation(.default, value: store.demoMode)
        .fileImporter(
            isPresented: $showPicker,
            allowedContentTypes: [UTType(filenameExtension: "p8")!],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    readP8File(url)
                    
                    let keyId = url.lastPathComponent // AuthKey_3U3CPFA54N.p8
                        .replacingOccurrences(of: "AuthKey_", with: "")
                        .replacingOccurrences(of: ".p8", with: "")
                    
                    store.privateKeyId = keyId
                }
                
            case .failure(let error):
                print("Failed to pick file:", error.localizedDescription)
            }
        }
    }
    
    private func readP8File(_ url: URL) {
        let access = url.startAccessingSecurityScopedResource()
        
        defer {
            if access {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            let contents = try String(contentsOf: url, encoding: .utf8)
            
            let lines = contents
                .components(separatedBy: .newlines)
                .filter { line in
                    !line.trimmingCharacters(in: .whitespaces).isEmpty &&
                    line != "-----BEGIN PRIVATE KEY-----" &&
                    line != "-----END PRIVATE KEY-----"
                }
            
            store.privateKey = lines.joined()
        } catch {
            print("Failed to read file:", error.localizedDescription)
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(ValueStore())
}
