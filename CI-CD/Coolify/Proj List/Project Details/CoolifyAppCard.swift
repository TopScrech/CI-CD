import SwiftUI

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
                Button("Deploy", systemImage: "play") {
                    deploy()
                }
                
                Button {
                    deploy(true)
                } label: {
                    Text("Force deploy")
                    Text("Without cache")
                    Image(systemName: "play")
                }
            }
            
            Section {
                Button("Restart", systemImage: "arrow.trianglehead.2.clockwise.rotate.90", action: restart)
                Button("Stop", systemImage: "stop", action: stop)
            }
            
            if let urlString = app.gitRepository, let url = URL(string: urlString) {
                Button("Open on GitHub", systemImage: "link") {
                    openURL(url)
                }
            }
        }
    }
    
    private func restart() {
        Task {
            await vm.restart(app.uuid, store: store)
        }
    }
    
    private func stop() {
        Task {
            await vm.stop(app.uuid, store: store)
        }
    }
    
    private func deploy(_ force: Bool = false) {
        Task {
            await vm.deploy(app.uuid, force: force, store: store)
        }
    }
}

//#Preview {
//    List {
//        CoolifyAppCard()
//    }
//    .darkSchemePreferred()
//}
