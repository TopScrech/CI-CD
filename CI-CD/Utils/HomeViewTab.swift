import Foundation
import SwiftUI

enum HomeViewTab: String, CaseIterable, Identifiable {
    case connect, coolify, github
    
    var id: String { rawValue }

    var title: String {
        switch self {
        case .connect: String(localized: "Connect")
        case .coolify: String(localized: "Coolify")
        case .github: String(localized: "GitHub")
        }
    }
    
    var localizedTitle: LocalizedStringKey {
        switch self {
        case .connect: "Connect"
        case .coolify: "Coolify"
        case .github: "GitHub"
        }
    }
    
    var systemImage: String {
        switch self {
        case .connect: "app.dashed"
        case .coolify: "globe"
        case .github: "checkmark.seal"
        }
    }
    
    var visibilityID: String {
        rawValue
    }
}
