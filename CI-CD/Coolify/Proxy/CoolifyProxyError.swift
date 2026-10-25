import Foundation

enum CoolifyProxyError: LocalizedError {
    case invalidURL, missingUsername, missingPassword, missingCredentials
    case keychain(Int32)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            String(localized: "Enter an HTTPS proxy URL without a path, username, or password")
        case .missingUsername:
            String(localized: "Enter the proxy username")
        case .missingPassword:
            String(localized: "Enter the proxy password")
        case .missingCredentials:
            String(localized: "Proxy credentials are not available yet — check iCloud Keychain or save them in account settings")
        case .keychain(let status):
            String(localized: "Couldn’t access proxy settings in iCloud Keychain (\(status))")
        }
    }
}
