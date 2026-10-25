import SwiftUI

// Scrolling the sidebar must never minimize the navigation bar of the selected tab
struct PanelSidebarBarMinimization: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 27, *) {
            content
                .scrollEdgeEffectHidden(for: .top)
                .toolbarMinimizationBehavior(.never, for: .navigationBar)
        } else if #available(iOS 26, *) {
            content
                .scrollEdgeEffectHidden(for: .top)
        } else {
            content
        }
        #else
        content
        #endif
    }
}

extension View {
    func panelSidebarBarMinimizationDisabled() -> some View {
        modifier(PanelSidebarBarMinimization())
    }
}
