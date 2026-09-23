import ScrechKit

struct CoolifyAppCard: View {
    @State private var vm = CoolifyAppVM()
    @State private var appDetailsVM = CoolifyAppDetailsVM()
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var store: ValueStore
    
    private let app: CoolifyApp
    
    init(_ app: CoolifyApp) {
        self.app = app
    }
    
    var body: some View {
        NavigationLink {
            CoolifyAppDetails(app)
                .environment(vm)
                .environment(appDetailsVM)
        } label: {
            VStack(alignment: .leading) {
                Text(app.name)
                
                if let description = app.description, !description.isEmpty {
                    Text(description)
                        .footnote()
                        .secondary()
                }
            }
        }
        .task {
            appDetailsVM.newName = app.name
        }
        .contextMenu {
            Section {
                AsyncButton("Deploy", systemImage: "play") {
                    await vm.deploy(app.uuid, force: false, store: store)
                }
                
                AsyncButton {
                    await vm.deploy(app.uuid, force: true, store: store)
                } label: {
                    Text("Force deploy")
                    Text("Without cache")
                    Image(systemName: "play")
                }
            }
            
            Section {
                AsyncButton("Restart", systemImage: "arrow.trianglehead.2.clockwise.rotate.90") {
                    await vm.restart(app.uuid, store: store)
                }
                
                AsyncButton("Stop", systemImage: "stop") {
                    await vm.stop(app.uuid, store: store)
                }
            }
            
            if let urlString = app.gitRepository, let url = URL(string: urlString) {
                Button("Open on GitHub", systemImage: "link") {
                    openURL(url)
                }
            }
        }
    }
}

//#Preview {
//    List {
//        CoolifyAppCard()
//    }
//    .darkSchemePreferred()
//}
