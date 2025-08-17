import SwiftUI

final class ValueStore: ObservableObject {
    @AppStorage("is_authorized") var isAuthorized = false
    @AppStorage("issuer") var issuer = ""
    @AppStorage("private_key") var privateKey = ""
    @AppStorage("private_key_id") var privateKeyId = ""
    
    @AppStorage("appearance") var appearance: ColorTheme = .system
    
    @AppStorage("demo_mode") var demoMode = false
}
