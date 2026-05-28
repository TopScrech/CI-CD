import Foundation

@Observable
final class PanelSidebarCustomizationVM {
    private let hiddenTabsDefaultsKey = "panel.sidebar.hiddenTabs.v1"
    private let placementDefaultsKey = "panel.sidebar.placement.v1"
    
    var tabVisibility: [HomeViewTab: Bool] {
        didSet {
            persistHiddenTabs()
        }
    }
    
    var placement: PanelSidebarPlacement {
        didSet {
            persistPlacement()
        }
    }
    
    init() {
        tabVisibility = Dictionary(uniqueKeysWithValues: HomeViewTab.allCases.map {
            ($0, true)
        })
        
        placement = .left
        
        loadHiddenTabs()
        loadPlacement()
    }
    
    var visibleSections: [PanelSidebarSection] {
        PanelSidebarSection.all.compactMap { section in
            let visibleTabs = section.tabs.filter {
                isTabVisible($0)
            }
            
            guard !visibleTabs.isEmpty else { return nil }
            return PanelSidebarSection(key: section.key, tabs: visibleTabs)
        }
    }
    
    var firstVisibleTab: HomeViewTab? {
        PanelSidebarSection.all
            .flatMap(\.tabs)
            .first { isTabVisible($0) }
    }
    
    func isTabVisible(_ tab: HomeViewTab) -> Bool {
        tabVisibility[tab, default: true]
    }
    
    func setTabVisible(_ isVisible: Bool, for tab: HomeViewTab) {
        tabVisibility[tab] = isVisible
    }
    
    func toggleTabVisibility(_ tab: HomeViewTab) {
        setTabVisible(!isTabVisible(tab), for: tab)
    }
    
    func reset() {
        tabVisibility = Dictionary(uniqueKeysWithValues: HomeViewTab.allCases.map { ($0, true) })
        placement = .left
    }
}

private extension PanelSidebarCustomizationVM {
    func loadHiddenTabs() {
        guard let hiddenTabs = UserDefaults.standard.array(forKey: hiddenTabsDefaultsKey) as? [String] else {
            return
        }
        
        let hiddenTabIDs = Set(hiddenTabs)
        var visibility = Dictionary(uniqueKeysWithValues: HomeViewTab.allCases.map { ($0, true) })
        
        for tab in HomeViewTab.allCases {
            if hiddenTabIDs.contains(tab.visibilityID) {
                visibility[tab] = false
            }
        }
        
        tabVisibility = visibility
    }
    
    func persistHiddenTabs() {
        let hiddenTabs = HomeViewTab.allCases
            .filter { tabVisibility[$0, default: true] == false }
            .map(\.visibilityID)
        
        UserDefaults.standard.set(hiddenTabs, forKey: hiddenTabsDefaultsKey)
    }
    
    func loadPlacement() {
        guard
            let rawValue = UserDefaults.standard.string(forKey: placementDefaultsKey),
            let placement = PanelSidebarPlacement(rawValue: rawValue)
        else {
            return
        }
        
        self.placement = placement
    }
    
    func persistPlacement() {
        UserDefaults.standard.set(placement.rawValue, forKey: placementDefaultsKey)
    }
}
