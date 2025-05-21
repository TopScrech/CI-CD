import SwiftUI

struct TransparentList: ViewModifier {
    func body(content: Content) -> some View {
        content
#if os(iOS)
            .scrollContentBackground(.hidden)
            .presentationBackground(.ultraThinMaterial)
#endif
    }
}

extension View {
    func transparentList() -> some View {
        modifier(TransparentList())
    }
}
