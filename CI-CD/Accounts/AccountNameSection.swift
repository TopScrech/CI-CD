import SwiftUI

struct AccountNameSection: View {
    let account: ProviderAccount
    
    var body: some View {
        @Bindable var account = account
        
        Section("Account name") {
            TextField("Name (optional)", text: $account.name)
                .autocorrectionDisabled()
                .onChange(of: account.name) {
                    account.touch()
                }
        }
    }
}
