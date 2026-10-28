import Foundation

enum ConnectWebError: LocalizedError {
    case signInRequired, recoveryFailed, accessDenied, wrongTeam, summaryUnavailable
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .signInRequired: String(localized: "Sign in to App Store Connect to load build environment and timing")
        case .recoveryFailed: String(localized: "Could not restore your App Store Connect session automatically. Sign in again to continue")
        case .accessDenied: String(localized: "Your Apple Account does not have permission to access this App Store Connect resource")
        case .wrongTeam: String(localized: "Select the connected team in App Store Connect and try again")
        case .summaryUnavailable: String(localized: "Could not read the build summary from App Store Connect")
        case .httpStatus(let status): String(localized: "Could not load the build summary") + " (HTTP \(status))"
        }
    }

    var requiresSignIn: Bool {
        switch self {
        case .signInRequired, .recoveryFailed, .wrongTeam: true
        default: false
        }
    }

    static func decodingDescription(_ error: DecodingError) -> String {
        let path: [any CodingKey]
        switch error {
        case .keyNotFound(let key, let context): path = context.codingPath + [key]
        case .typeMismatch(_, let context), .valueNotFound(_, let context), .dataCorrupted(let context): path = context.codingPath
        @unknown default: path = []
        }
        let field = path.map(\.stringValue).joined(separator: ".")
        let message = String(localized: "Could not read the build summary from App Store Connect")
        return field.isEmpty ? message : "\(message) (\(field))"
    }
}
