import SwiftUI

struct CoolifyProxySettingsView: View {
    @Environment(CoolifyProxySettingsVM.self) private var vm

    var body: some View {
        @Bindable var vm = vm

        Section {
            Toggle("Use proxy", isOn: $vm.isEnabled)

            if vm.isEnabled {
                TextField("Proxy URL", text: $vm.credentials.url)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                TextField("Proxy username", text: $vm.credentials.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                SecureField("Proxy password", text: $vm.credentials.password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            if let errorMessage = vm.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        } header: {
            Text("Proxy")
        } footer: {
            Text("Saved in iCloud Keychain")
        }
    }
}
