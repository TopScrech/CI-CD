import ScrechKit
import OSLog

struct CoolifyAppDetails: View {
    @Environment(CoolifyAppVM.self) private var appVM
    @Environment(CoolifyAppDetailsVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    @Environment(\.openURL) private var openURL
    
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
                        Button("Open", systemImage: "safari") {
                            openURL(url)
                        }
                        
                        ShareLink(item: url)
                    } label: {
                        LabeledContent("URL", value: urlString)
                            .tint(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                
                if let gitRepoURL = app.gitRepoURL {
                    Menu {
                        Button("Open", systemImage: "safari") {
                            openURL(gitRepoURL)
                        }
                        
                        ShareLink(item: gitRepoURL)
                    } label: {
                        LabeledContent("Repository", value: gitRepoURL.description)
                            .tint(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                
                if let branch = app.gitBranch {
                    LabeledContent("Branch", value: branch)
                }
                
                if vm.isLoadingBuildPacks && vm.availableBuildPacks.isEmpty {
                    HStack {
                        Text("Build pack")
                        Spacer()
                        ProgressView()
                    }
                } else if !vm.availableBuildPacks.isEmpty {
                    Picker("Build pack", selection: $vm.newBuildPack) {
                        ForEach(vm.availableBuildPacks) {
                            Text($0.title)
                                .tag($0.rawValue)
                        }
                    }
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
            resetAndLoad()
        }
        .onChange(of: store.coolifyAccount?.id) {
            resetAndLoad()
        }
        .onChange(of: store.coolifyDemoMode) {
            resetAndLoad()
        }
        .onChange(of: store.coolifyRefreshToken) {
            resetAndLoad()
        }
        .toolbar {
            Menu {
                Button("Rename", systemImage: "pencil") {
                    vm.newName = app.name
                    vm.newDescription = app.description ?? ""
                    alertRename = true
                }
                
                Section {
                    AsyncButton("Deploy", systemImage: "play") {
                        await appVM.deploy(app.uuid, force: false, store: store)
                    }
                    
                    AsyncButton {
                        await appVM.deploy(app.uuid, force: true, store: store)
                    } label: {
                        Text("Force deploy")
                        Text("Without cache")
                        Image(systemName: "play")
                    }
                }
                
                Section {
                    AsyncButton("Restart", systemImage: "arrow.trianglehead.2.clockwise.rotate.90") {
                        await appVM.restart(app.uuid, store: store)
                    }
                    
                    AsyncButton("Stop", systemImage: "stop") {
                        await appVM.stop(app.uuid, store: store)
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
            }
        }
        .alert("Rename", isPresented: $alertRename) {
            TextField("New name", text: $vm.newName)
                .autocorrectionDisabled()
            
            TextField("New description", text: $vm.newDescription)
            Button("Cancel", role: .cancel) {}
            AsyncButton("Save", action: save)
        }
        .onChange(of: vm.newBuildPack) { oldValue, newValue in
            guard
                !vm.isPreparingBuildPack,
                !vm.isSaving,
                !newValue.isEmpty,
                newValue != oldValue,
                newValue != app.buildPack
            else {
                return
            }
            
            Task {
                await save()
            }
        }
    }
    
    private func resetAndLoad() {
        Task {
            vm.resetLoading()
            await load()
        }
    }
    
    private func save() async {
        if let app = await vm.renameApp(app, store: store) {
            self.app = app
            Logger().info("New app name: \(app.name)")
        } else {
            Logger().warning("New app object not returned")
        }
    }
    
    private func load() async {
        await vm.prepareEditor(for: app, store: store)
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
