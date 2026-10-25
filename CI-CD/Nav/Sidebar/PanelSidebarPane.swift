import SwiftUI

struct PanelSidebarPane: View {
    let width: Double
    let onSelect: (HomeViewTab) -> Void

    var body: some View {
        PanelSidebarList(onSelect: onSelect)
            .frame(width: width)
            .frame(maxHeight: .infinity)
            .background(.thickMaterial)
    }
}
