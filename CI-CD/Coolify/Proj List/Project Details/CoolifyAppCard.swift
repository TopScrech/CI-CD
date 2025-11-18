import SwiftUI

struct CoolifyAppCard: View {
    @Environment(\.openURL) private var openURL
    
    private let app: CoolifyApp
    
    init(_ app: CoolifyApp) {
        self.app = app
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(app.name)
            
            if let description = app.description, !description.isEmpty {
                Text(description)
                    .footnote()
                    .secondary()
            }
        }
        .contextMenu {
            if let url = app.gitFullUrl {
                Button("Open on GitHub", systemImage: "link") {
                    openURL(URL(string: url)!)
                }
            }
        }
    }
}

//#Preview {
//    CoolifyAppCard()
//        .darkSchemePreferred()
//}
