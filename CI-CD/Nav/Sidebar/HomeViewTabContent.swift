import SwiftUI

struct HomeViewTabContent: View {
    let selectedTab: HomeViewTab
    
    var body: some View {
        switch selectedTab {
        case .connect: ConnectAppList()
        case .coolify: CoolifyProjList()
        case .github: GitHubRepoList()
        }
    }
}

#Preview {
    HomeViewTabContent(selectedTab: .connect)
        .darkSchemePreferred()
        .environmentObject(ValueStore())
        .modelContainer(PreviewModelContainer.inMemory)
}
