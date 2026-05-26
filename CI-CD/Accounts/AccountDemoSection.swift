import SwiftUI

struct AccountDemoSection: View {
    let account: ProviderAccount
    let onChange: () -> Void
    
    var body: some View {
        @Bindable var account = account
        
        Section("Account mode") {
            Toggle("Demo mode", isOn: $account.demoMode)
                .onChange(of: account.demoMode) {
                    account.touch()
                    onChange()
                }
        }
    }
}
