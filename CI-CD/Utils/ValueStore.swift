import SwiftUI

final class ValueStore: ObservableObject {
    @AppStorage("is_authorized") var isAuthorized = false
    @AppStorage("issuer") var issuer = ""
    @AppStorage("private_key") var privateKey = ""
    @AppStorage("private_key_id") var privateKeyId = ""
    @AppStorage("last_tab") var lastTab = 0
    @AppStorage("show_status_bar") var showStatusBar = true
    
    @AppStorage("demo_mode") var demoMode = false
#if os(iOS)
    @AppStorage("appearance") var appearance: ColorTheme = .system
#endif
}
