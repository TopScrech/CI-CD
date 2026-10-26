import Foundation

enum ConnectWebError: LocalizedError {
    case signInRequired, wrongTeam, summaryUnavailable
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .signInRequired: String(localized: "Sign in to App Store Connect to load build environment and timing")
        case .wrongTeam: String(localized: "Select the connected team in App Store Connect and try again")
        case .summaryUnavailable: String(localized: "Could not read the build summary from App Store Connect")
        case .httpStatus(let status): String(localized: "Could not load the build summary") + " (HTTP \(status))"
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
