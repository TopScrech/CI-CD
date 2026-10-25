import ScrechKit

#if os(iOS)
struct PanelSidebarView: View {
    private let edgeSwipeWidth: CGFloat = 24

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @EnvironmentObject private var store: ValueStore

    @State private var offset = 0.0
    @State private var lastDragOffset = 0.0
    @State private var panGesture: UIPanGestureRecognizer?

    @Binding var sidebarProgress: Double

    var body: some View {
        // The sidebar is a sibling of the tab content, so switching tabs never recreates it or resets its scroll position
        HStack(spacing: 0) {
            if isPersistent {
                PanelSidebarPane(width: sidebarWidth, onSelect: select)
            }
            
            HomeViewTabContent(selectedTab: store.lastTab)
                .id(store.lastTab)
                .transition(.opacity)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(.rect)
                .accessibilityHidden(!isPersistent && sidebarProgress > 0)
        }
        .overlay(alignment: .leading) {
            if !isPersistent {
                PanelSidebarDrawer(
                    width: sidebarWidth,
                    offset: offset,
                    progress: sidebarProgress,
                    onSelect: select,
                    onClose: closeSidebar
                )
            }
        }
        .toolbar {
            if !isPersistent {
                ToolbarItem(placement: .topBarLeading) {
                    Button(sidebarProgress > 0 ? "Close sidebar" : "Open sidebar", systemImage: "sidebar.left", action: toggleSidebar)
                        .labelStyle(.iconOnly)
                }
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: store.lastTab)
        .gesture(PanelCustomGesture(handle: handleDrag, shouldBegin: shouldBeginDrag))
        .onChange(of: isPersistent) { _, newValue in
            panGesture?.isEnabled = !newValue
            sidebarProgress = 0
            offset = 0
            lastDragOffset = 0
        }
        .background {
            Button(action: selectPreviousTab) {
                EmptyView()
            }
            .keyboardShortcut(.upArrow, modifiers: [.option])
            .frame(0)
            .opacity(0)
            .accessibilityHidden(true)

            Button(action: selectNextTab) {
                EmptyView()
            }
            .keyboardShortcut(.downArrow, modifiers: [.option])
            .frame(0)
            .opacity(0)
            .accessibilityHidden(true)
        }
    }

    private var isPersistent: Bool {
        if horizontalSizeClass == .compact {
            verticalSizeClass == .compact
        } else {
            horizontalSizeClass == .regular
        }
    }

    private var sidebarWidth: Double {
        isPersistent ? 220 : 250
    }

    private var sidebarAnimation: Animation? {
        reduceMotion
        ? nil
        : .snappy(duration: 0.25, extraBounce: 0)
    }

    private func select(_ tab: HomeViewTab) {
        closeSidebar()

        guard store.lastTab != tab else { return }

        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.5)) {
            store.lastTab = tab
        }
    }

    private func handleDrag(_ gesture: UIPanGestureRecognizer) {
        if panGesture == nil {
            panGesture = gesture
        }

        let translation = gesture.translation(in: gesture.view).x + lastDragOffset
        let velocity = gesture.velocity(in: gesture.view).x / 3

        switch gesture.state {
        case .began, .changed:
            let nextOffset = max(min(translation, sidebarWidth), 0)

            if offset == 0 && nextOffset > 0 {
                dismissTextFields()
            }

            offset = nextOffset
            sidebarProgress = offset / sidebarWidth

        default:
            withAnimation(sidebarAnimation) {
                if velocity + offset > sidebarWidth * 0.5 {
                    offset = sidebarWidth
                    sidebarProgress = 1
                } else {
                    offset = 0
                    sidebarProgress = 0
                }
            }

            lastDragOffset = offset
        }
    }

    private func shouldBeginDrag(_ gesture: UIPanGestureRecognizer) -> Bool {
        guard !isPersistent else {
            return false
        }

        let velocity = gesture.velocity(in: gesture.view)

        guard abs(velocity.x) > abs(velocity.y) else {
            return false
        }

        if offset > 0 {
            return velocity.x < 0
        }

        let startX = gesture.location(in: gesture.view).x
        return startX > edgeSwipeWidth && velocity.x > 0
    }

    private func toggleSidebar() {
        guard offset == 0 else {
            closeSidebar()
            return
        }

        dismissTextFields()

        withAnimation(sidebarAnimation) {
            sidebarProgress = 1
            offset = sidebarWidth
            lastDragOffset = sidebarWidth
        }
    }

    private func closeSidebar() {
        withAnimation(sidebarAnimation) {
            sidebarProgress = 0
            offset = 0
            lastDragOffset = 0
        }
    }

    private func dismissTextFields() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func selectPreviousTab() {
        selectTab(offset: -1)
    }

    private func selectNextTab() {
        selectTab(offset: 1)
    }

    private func selectTab(offset: Int) {
        let tabs = PanelSidebarSection.all.flatMap(\.tabs)

        guard !tabs.isEmpty else {
            return
        }

        guard let currentIndex = tabs.firstIndex(of: store.lastTab) else {
            store.lastTab = tabs[0]
            return
        }

        let count = tabs.count
        let nextIndex = (currentIndex + offset + count) % count

        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
            store.lastTab = tabs[nextIndex]
        }
    }
}

#Preview {
    @Previewable @State var sidebarProgress = 0.0

    PanelSidebarView(sidebarProgress: $sidebarProgress)
        .environmentObject(ValueStore())
        .modelContainer(PreviewModelContainer.inMemory)
}
#endif
