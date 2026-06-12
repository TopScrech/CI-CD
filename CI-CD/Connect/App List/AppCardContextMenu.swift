import ScrechKit
import AppStoreConnect_Swift_SDK
import OSLog

struct AppCardContextMenu: ViewModifier {
    @Environment(AppVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    @Binding private var sheetVersions: Bool
    private let product: CiProduct
    
    init(_ sheetVersions: Binding<Bool>, product: CiProduct) {
        _sheetVersions = sheetVersions
        self.product = product
    }
    
    func body(content: Content) -> some View {
        content
            .contextMenu {
                ForEach(vm.workflows) { workflow in
                    if let name = workflow.attributes?.name {
                        Section {
                            Button {
                                Task {
                                    do {
                                        try await vm.startBuild(workflow.id, store: store)
                                    } catch {
                                        Logger().error("Failed to start build: \(error)")
                                    }
                                }
                            } label: {
                                Text("Start build")
                                
                                Text(name)
                                
                                Image(systemName: "play")
                            }
                            
                            Button {
                                Task {
                                    do {
                                        try await vm.startBuild(workflow.id, clean: true, store: store)
                                    } catch {
                                        Logger().error("Failed to start clean build: \(error)")
                                    }
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
                        Button("AltStore Helper", systemImage: "app.dashed") {
                            sheetVersions = true
                        }
                    }
                }
#if DEBUG
                Section {
                    Button {
                        Pasteboard.copy(product.id)
                    } label: {
                        Text(String("Copy product id"))
                        Text(product.id)
                        Image(systemName: "doc.on.doc")
                    }
                    
                    if let appId = product.relationships?.app?.data?.id {
                        Button {
                            Pasteboard.copy(appId)
                        } label: {
                            Text(String("Copy app id"))
                            Text(appId)
                            Image(systemName: "doc.on.doc")
                        }
                    }
                }
#endif
            }
    }
}

extension View {
    func appCardContextMenu(_ sheetVersions: Binding<Bool>, product: CiProduct) -> some View {
        modifier(AppCardContextMenu(sheetVersions, product: product))
    }
}
