import Foundation

@Observable
final class CoolifyProxySettingsVM {
    var isEnabled = false
    var credentials = CoolifyProxyCredentials()
    var errorMessage: String?
    private var accountID: UUID?
    private var loadedSuccessfully = false

    func load(account: ProviderAccount) {
        accountID = account.id
        isEnabled = account.coolifyProxyEnabled
        credentials = CoolifyProxyCredentials()
        errorMessage = nil
        loadedSuccessfully = false
        do {
            credentials = try CoolifyProxyKeychain.load(accountID: account.id) ?? CoolifyProxyCredentials()
            loadedSuccessfully = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save(account: ProviderAccount) -> Bool {
        guard accountID == account.id else { return false }
        do {
            if isEnabled {
                _ = try credentials.configuration()
            }
            // Do not overwrite unavailable synced credentials with empty defaults
            if loadedSuccessfully {
                credentials.url = credentials.url.trimmingCharacters(in: .whitespacesAndNewlines)
                try CoolifyProxyKeychain.save(credentials, accountID: account.id)
            } else if isEnabled {
                throw CoolifyProxyError.missingCredentials
            }
            account.coolifyProxyEnabled = isEnabled
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
