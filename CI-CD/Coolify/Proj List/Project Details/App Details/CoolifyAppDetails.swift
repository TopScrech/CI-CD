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
                            .foregroundStyle(.foreground)
                    }
                }
                
                if let urlString = app.gitFullUrl, let url = URL(string: urlString) {
                    Menu {
                        Button("Open") {
                            openURL(url)
                        }
                        
                        ShareLink(item: url)
                    } label: {
                        LabeledContent("Repository", value: urlString)
                    }
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
            gitFullUrl: "https://github.com/cool/repo",
            fqdn: "demo.example.com",
            environmentName: "Production"
        )
    )
    .darkSchemePreferred()
}
