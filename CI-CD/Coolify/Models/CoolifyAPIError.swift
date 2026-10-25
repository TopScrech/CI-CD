import Foundation

enum CoolifyAPIError: LocalizedError {
    case invalidResponse
    case requestFailed(statusCode: Int, message: String?)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            String(localized: "Coolify returned an invalid response")
        case .requestFailed(let statusCode, let message):
            if let message, !message.isEmpty {
                String(localized: "Coolify request failed (HTTP \(statusCode)): \(message)")
            } else {
                String(localized: "Coolify request failed (HTTP \(statusCode))")
            }
        }
    }
}
