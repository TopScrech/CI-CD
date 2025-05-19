import SwiftUI
import UniformTypeIdentifiers

struct AuthView: View {
    @EnvironmentObject private var store: ValueStore
    
    @State private var showPicker = false
    
    private var disabled: Bool {
        store.issuer.isEmpty || store.privateKey.isEmpty || store.privateKeyId.isEmpty
    }
    
    var body: some View {
        List {
            HStack {
                TextField("Issuer", text: $store.issuer)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                
                PasteButton(payloadType: String.self) { paste in
                    if let issuer = paste.first, issuer.count == 36 {
                        store.issuer = issuer
                    }
                }
            }
            
            Section("Private Key") {
                TextEditor(text: $store.privateKey)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                
                TextField("Private Key ID", text: $store.privateKeyId)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                
                Button("File Picket") {
                    showPicker = true
                }
            }
            
            Section {
                Button("Authorize") {
                    store.isAuthorized = true
                }
                .disabled(disabled)
            }
        }
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
