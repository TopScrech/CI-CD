import Foundation
import SwiftUI

enum HomeViewTab: String, CaseIterable, Identifiable {
    case connect, coolify
    
    var id: String { rawValue }

    var title: String {
        switch self {
        case .connect: String(localized: "Connect")
        case .coolify: String(localized: "Coolify")
        }
    }
    
    var localizedTitle: LocalizedStringKey {
        switch self {
        case .connect: "Connect"
        case .coolify: "Coolify"
        }
    }
    
    var systemImage: String {
        switch self {
        case .connect: "app.dashed"
        case .coolify: "globe"
        }
    }
    
    var visibilityID: String {
        rawValue
    }
}
