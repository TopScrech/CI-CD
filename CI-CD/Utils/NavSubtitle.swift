import SwiftUI

extension View {
    @ViewBuilder
    func navSubtitle(_ subtitle: LocalizedStringKey) -> some View {
#if os(visionOS) || os(tvOS)
        self
#else
        if #available(iOS 26, *) {
            self
                .navigationSubtitle(subtitle)
        } else {
            self
        }
#endif
    }
    
    func navSubtitle<T: CustomStringConvertible>(_ subtitle: T) -> some View {
        navSubtitle(LocalizedStringKey(subtitle.description))
    }
}
