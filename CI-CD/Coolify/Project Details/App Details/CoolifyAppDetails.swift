import SwiftUI

struct CoolifyAppDetails: View {
    @State private var vm = CoolifyAppDetailsVM()
    private let app: CoolifyApp
    
    init(_ app: CoolifyApp) {
        self.app = app
    }
    
    var body: some View {
        List {
            Section("App") {
                LabeledContent("Name", value: app.name)
                
                if let description = app.description, !description.isEmpty {
                    LabeledContent("Description", value: description)
                }
                
                if let env = app.environmentName {
                    LabeledContent("Environment", value: env)
                }
                
                if let fqdn = app.fqdn, !fqdn.isEmpty {
                    LabeledContent("URL", value: fqdn)
                }
                
                if let git = app.gitFullUrl, let url = URL(string: git) {
                    Link("Repository", destination: url)
                }
            }
            
            Section("Deployments") {
                if vm.deployments.isEmpty {
                    ContentUnavailableView("No deployments yet", systemImage: "shippingbox")
                } else {
                    ForEach(vm.deployments) {
                        DeploymentCard($0)
                    }
                }
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
