import SwiftUI

struct CoolifyAppCard: View {
    @State private var vm = CoolifyAppVM()
    @Environment(\.openURL) private var openURL
    
    private let app: CoolifyApp
    
    init(_ app: CoolifyApp) {
        self.app = app
    }
    
    var body: some View {
        NavigationLink {
            CoolifyAppDetails(app)
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
                Button("Restart", systemImage: "arrow.trianglehead.2.clockwise.rotate.90") {
                    Task {
                        await vm.restart(app.uuid)
                    }
                }
                
                Button("Stop", systemImage: "stop") {
                    Task {
                        await vm.stop(app.uuid)
                    }
                }
            }
            
            if let urlString = app.gitRepository, let url = URL(string: urlString) {
                Button("Open on GitHub", systemImage: "link") {
                    openURL(url)
                }
            }
        }
    }
    
    private func deploy(_ force: Bool = false) {
        Task {
            await vm.deploy(app.uuid, force: force)
        }
    }
}

//#Preview {
//    List {
//        CoolifyAppCard()
//    }
//    .darkSchemePreferred()
//}
