import Foundation

enum HomeViewTab: String {
    case connect, coolify

    var title: String {
        switch self {
        case .connect: String(localized: "Connect")
        case .coolify: String(localized: "Coolify")
        }
    }
}
