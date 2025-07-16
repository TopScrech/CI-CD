import SwiftUI
import AppStoreConnect_Swift_SDK

struct AppCard: View {
    @State private var vm = AppVM()
    @EnvironmentObject private var store: ValueStore
    
    private let product: CiProduct
    
    init(_ product: CiProduct) {
        self.product = product
    }
    
    @State private var sheetVersions = false
    
    var body: some View {
        NavigationLink {
            ProductDetails(product)
                .environment(vm)
        } label: {
            HStack {
                AppCardImage(product)
                    .environment(vm)
                
                VStack(alignment: .leading) {
                    if let attributes = product.attributes, let name = attributes.name {
                        Text(name)
                            .title3()
                    }
#if DEBUG
                    if let bundleId = product.relationships?.bundleID?.data?.id {
                        Text(bundleId)
                            .secondary()
                            .footnote()
                    }
#endif
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(vm.workflows) { workflow in
                        Text(workflow.attributes?.name ?? "")
                            .secondary()
                            .footnote()
                    }
                }
            }
        }
        .sheet($sheetVersions) {
            NavigationView {
                if let appId = product.relationships?.app?.data?.id {
                    AppVersions(appId)
                        .environment(vm)
                } else {
                    Text("Error")
                }
            }
        }
        .task {
            if store.demoMode {
                vm.workflows = [CiWorkflow.preview]
            } else {
                async let workflows: () = vm.fetchWorkflows(product.id)
                async let builds: () = vm.fetchBuilds(product.id)
                async let primaryRepos: () = vm.primaryRepositories(product.id)
                async let additionalRepos: () = vm.additionalRepositories(product.id)
                async let versions: () = vm.getVersions(product.relationships?.app?.data?.id)
                
                _ = try? await (workflows, builds, additionalRepos, primaryRepos, versions)
            }
        }
        .contextMenu {
            ForEach(vm.workflows) { workflow in
                if let name = workflow.attributes?.name {
                    Section {
                        Button {
                            Task {
                                try await vm.startBuild(workflow.id)
                            }
                        } label: {
                            Text("Start build")
                            
                            Text(name)
                            
                            Image(systemName: "play")
                        }
                        
                        Button {
                            Task {
                                try await vm.startBuild(workflow.id, clean: true)
                            }
                        } label: {
                            Text("Start clean build")
                            
                            Text(name)
                            
                            Image(systemName: "play")
                        }
                    }
                }
            }
            
            if let _ = product.relationships?.app?.data?.id {
                Section {
                    Button {
                        sheetVersions = true
                    } label: {
                        Label("AltStore Helper", systemImage: "app.dashed")
                    }
                }
            }
#if DEBUG
            Section {
                Button {
                    UIPasteboard.general.string = product.id
                } label: {
                    Text("Copy product id")
                    
                    Text(product.id)
                    
                    Image(systemName: "doc.on.doc")
                }
                
                if let appId = product.relationships?.app?.data?.id {
                    Button {
                        UIPasteboard.general.string = appId
                    } label: {
                        Text("Copy app id")
                        
                        Text(appId)
                        
                        Image(systemName: "doc.on.doc")
                    }
                }
            }
#endif
        }
    }
}

#Preview {
    AppCard(CiProduct.preview)
        .environmentObject(ValueStore())
}
