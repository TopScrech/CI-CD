import OSLog
import SwiftUI

struct CoolifyAppDetails: View {
    @Environment(CoolifyAppDetailsVM.self) private var vm
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var store: ValueStore
    
    @State private var app: CoolifyApp
    
    init(_ app: CoolifyApp) {
        self.app = app
    }
    
    @State private var alertRename = false
    
    var body: some View {
        @Bindable var vm = vm
        
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
                
                if let buildPack = app.buildPack {
                    LabeledContent("Build pack", value: buildPack)
                }
            }
            
            Section("Deployments") {
                CoolifyDeploymentList()
                    .environment(vm)
            }
        }
        .navigationTitle(app.name)
        .navSubtitle(app.description ?? "")
        .refreshableTask {
            vm.resetLoading()
            await load()
        }
        .task {
            vm.resetLoading()
            await load()
        }
        .onChange(of: store.coolifyAccount?.id) {
            Task {
                vm.resetLoading()
                await load()
            }
        }
        .onChange(of: store.coolifyDemoMode) {
            Task {
                vm.resetLoading()
                await load()
            }
        }
        .onChange(of: store.coolifyRefreshToken) {
            Task {
                vm.resetLoading()
                await load()
            }
        }
        .toolbar {
            Button("Rename", systemImage: "pencil") {
                vm.newName = app.name
                vm.newDescription = app.description ?? ""
                alertRename = true
            }
        }
        .alert("Rename", isPresented: $alertRename) {
            TextField("New name", text: $vm.newName)
            TextField("New description", text: $vm.newDescription)
            Button("Cancel", role: .cancel) {}
            Button("Save", action: save)
        }
    }
    
    private func save() {
        Task {
            if let app = await vm.renameApp(app, store: store) {
                self.app = app
                Logger().info("New app name: \(app.name)")
            } else {
                Logger().warning("New app object not returned")
            }
        }
    }

    private func load() async {
        await vm.fetchDeployments(app.uuid, store: store)
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
            buildPack: "Dockerfile",
            fqdn: "demo.example.com",
            environmentName: "Production"
        )
    )
    .darkSchemePreferred()
    .environment(CoolifyAppDetailsVM())
}
