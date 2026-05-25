import SwiftUI

struct PanelSidebarSection: Identifiable, Hashable {
    let key: Key
    let tabs: [HomeViewTab]
    
    var id: Key { key }
    var title: LocalizedStringKey { key.title }
}

extension PanelSidebarSection {
    enum Key: String, Identifiable {
        case services
        
        var id: String { rawValue }
        
        var title: LocalizedStringKey {
            switch self {
            case .services: "Services"
            }
        }
    }
    
    static let all = [
        PanelSidebarSection(
            key: .services,
            tabs: [
                .connect,
                .coolify,
                .github
            ]
        )
    ]
}
