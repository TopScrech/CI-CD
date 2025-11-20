import SwiftUI

#if canImport(Appearance)
import Appearance
#endif

final class ValueStore: ObservableObject {
    @AppStorage("last_tab") var lastTab = HomeViewTab.connect
    @AppStorage("demo_mode") var demoMode = false
#if os(iOS)
    @AppStorage("show_status_bar") var showStatusBar = true
#endif
    
#if canImport(Appearance)
    @AppStorage("appearance") var appearance: Appearance = .system
#endif
    
    @AppStorage("issuer") var issuer = ""
    @AppStorage("private_key") var privateKey = ""
    @AppStorage("private_key_id") var privateKeyId = ""
    
    @AppStorage("coolify_api_key") var coolifyAPIKey = ""
    @AppStorage("coolify_domain") var coolifyDomain = "https://coolify.example.com"
    
    var coolifyAuthorized: Bool {
        !coolifyDomain.isEmpty && !coolifyAPIKey.isEmpty
    }
    
    var connectAuthorized: Bool {
        !issuer.isEmpty && !privateKey.isEmpty && !privateKeyId.isEmpty
    }
}
