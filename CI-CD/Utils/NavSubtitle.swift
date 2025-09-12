import SwiftUI

// MARK: - Nav Subtitle
struct NavSubtitle: ViewModifier {
    private let subtitle: LocalizedStringKey
    
    init(_ subtitle: LocalizedStringKey) {
        self.subtitle = subtitle
    }
    
    init(_ subtitle: String) {
        self.subtitle = LocalizedStringKey(subtitle)
    }
    
    func body(content: Content) -> some View {
#if os(visionOS) || os(tvOS)
        content
#else
        if #available(iOS 26, *) {
            content
                .navigationSubtitle(subtitle)
        }
#endif
    }
}

extension View {
    func navSubtitle(_ subtitle: LocalizedStringKey) -> some View {
        modifier(NavSubtitle(subtitle))
    }
    
    func navSubtitle<T: CustomStringConvertible>(_ subtitle: T) -> some View {
        modifier(NavSubtitle(subtitle.description))
    }
}
