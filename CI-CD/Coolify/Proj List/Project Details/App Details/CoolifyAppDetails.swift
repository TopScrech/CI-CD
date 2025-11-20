import SwiftUI

struct CoolifyAppDetails: View {
    @State private var vm = CoolifyAppDetailsVM()
    @Environment(\.openURL) private var openURL
    
    private let app: CoolifyApp
    
    init(_ app: CoolifyApp) {
        self.app = app
    }
    
    var body: some View {
        List {
            Section("App") {
                if let env = app.environmentName {
                    LabeledContent("Environment", value: env)
                }
                
                if let urlString = app.fqdn, !urlString.isEmpty, let url = URL(string: urlString) {
                    Menu {
                        Button("Open") {
                            openURL(url)
                        }
                        
                        ShareLink(item: url)
                    } label: {
                        LabeledContent("URL", value: urlString)
                            .tint(.primary)
                    }
                }
                
                if let gitRepoURL = app.gitRepoURL {
                    Menu {
                        Button("Open") {
                            openURL(gitRepoURL)
                        }
                        
                        ShareLink(item: gitRepoURL)
                    } label: {
                        LabeledContent("Repository", value: gitRepoURL.description)
                            .tint(.primary)
                    }
                }
                
                if let branch = app.gitBranch {
                    LabeledContent("Branch", value: branch)
                }
            }
            
            Section("Deployments") {
                DeploymentList()
                    .environment(vm)
            }
        }
        .navigationTitle(app.name)
        .navSubtitle(app.description ?? "")
        .refreshableTask {
            await vm.fetchDeployments(app.uuid)
        }
    }
}

#Preview {
    CoolifyAppDetails(
        CoolifyApp(
            uuid: "uuid",
            environmentId: 1,
            repositoryProjectId: 1,
            name: "Demo App",
            description: "",
            gitRepository: "https://github.com/cool/repo",
            gitBranch: "main",
            fqdn: "demo.example.com",
            environmentName: "Production"
        )
    )
    .darkSchemePreferred()
}
