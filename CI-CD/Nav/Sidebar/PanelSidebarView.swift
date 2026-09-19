import ScrechKit

#if !os(visionOS)
struct PanelSidebarView: View {
    private let edgeSwipeWidth: CGFloat = 24
    
    @EnvironmentObject private var store: ValueStore
    
    @State private var offset = 0.0
    @State private var lastDragOffset = 0.0
    @State private var progress = 0.0
    @State private var panGesture: UIPanGestureRecognizer?
    
    var body: some View {
        PanelAdaptiveView { _, isLandscape in
            let sideBarWidth: CGFloat = isLandscape ? 220 : 250
            let layout = isLandscape
            ? AnyLayout(HStackLayout(spacing: 0))
            : AnyLayout(ZStackLayout(alignment: .leading))
            
            layout {
                PanelSidebarList { tab in
                    toggleSidebar()
                    
                    if store.lastTab == tab { return }
                    
                    withAnimation(.easeInOut(duration: 0.5)) {
                        store.lastTab = tab
                    }
                }
                .frame(width: sideBarWidth)
                .background(.thickMaterial)
                .offset(x: isLandscape ? 0 : -sideBarWidth + offset)
                
                ZStack {
                    HomeViewTabContent(selectedTab: store.lastTab)
                        .id(store.lastTab)
                        .transition(.opacity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(.rect)
                .overlay {
                    Rectangle()
                        .fill(.black.opacity(0.25))
                        .ignoresSafeArea()
                        .opacity(isLandscape ? 0 : progress)
                }
                .offset(x: isLandscape ? 0 : offset)
            }
            .animation(.easeInOut(duration: 0.5), value: store.lastTab)
            .gesture(
                PanelCustomGesture { gesture in
                    if panGesture == nil {
                        panGesture = gesture
                    }
                    
                    let state = gesture.state
                    let translationX = gesture.translation(in: gesture.view).x
                    let velocityX = gesture.velocity(in: gesture.view).x
                    let translation = translationX + lastDragOffset
                    let velocity = velocityX / 3
                    
                    if state == .began || state == .changed {
                        offset = max(min(translation, sideBarWidth), 0)
                        progress = max(min(offset / sideBarWidth, 1), 0)
                    } else {
                        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                            if (velocity + offset) > (sideBarWidth * 0.5) {
                                offset = sideBarWidth
                                progress = 1
                            } else {
                                offset = 0
                                progress = 0
                            }
                        }
                        
                        lastDragOffset = offset
                    }
                } shouldBegin: { gesture in
                    if isLandscape { return false }
                    
                    let startX = gesture.location(in: gesture.view).x
                    let isEdgeSwipe = startX <= edgeSwipeWidth
                    
                    return !(isEdgeSwipe && offset == 0)
                }
            )
            .onChange(of: isLandscape) { _, newValue in
                panGesture?.isEnabled = !newValue
            }
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
    
    private func toggleSidebar() {
        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
            progress = 0
            offset = 0
            lastDragOffset = 0
        }
    }
    
    private func selectPreviousTab() {
        selectVisibleTab(offset: -1)
    }
    
    private func selectNextTab() {
        selectVisibleTab(offset: 1)
    }
    
    private func selectVisibleTab(offset: Int) {
        let visibleTabs = PanelSidebarSection.all.flatMap(\.tabs)
        
        guard !visibleTabs.isEmpty else {
            return
        }
        
        guard let currentIndex = visibleTabs.firstIndex(of: store.lastTab) else {
            store.lastTab = visibleTabs[0]
            return
        }
        
        let count = visibleTabs.count
        let nextIndex = (currentIndex + offset + count) % count
        
        withAnimation(.easeInOut(duration: 0.25)) {
            store.lastTab = visibleTabs[nextIndex]
        }
    }
}

#Preview {
    PanelSidebarView()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
        .modelContainer(PreviewModelContainer.inMemory)
}
#endif
