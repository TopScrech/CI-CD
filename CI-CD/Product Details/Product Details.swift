import SwiftUI
import AppStoreConnect_Swift_SDK

struct ProductDetails: View {
    @Environment(ProductVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    private let product: CiProduct
    
    init(_ product: CiProduct) {
        self.product = product
    }
    
    private var authors: [CiGitUser] {
        Array(Set(vm.builds.compactMap(\.attributes?.sourceCommit?.author)))
    }
    
    private var filteredBuilds: [CiBuildRun] {
        if let selectedAuthor {
            vm.builds.filter {
                $0.attributes?.sourceCommit?.author?.displayName == selectedAuthor.displayName
            }
        } else {
            vm.builds
        }
    }
    
    @State private var selectedAuthor: CiGitUser?
    
    var body: some View {
        List {
            Section {
                ForEach(vm.workflows) { workflow in
                    WorkflowCard(workflow)
                }
            }
            
            Section {
                ForEach(filteredBuilds.reversed()) { build in
                    BuildCard(build)
                }
                .animation(.default, value: selectedAuthor)
            }
        }
        .navigationTitle(product.attributes?.name ?? "")
        .environment(vm)
        .toolbar {
            Menu {
                Section {
                    Button("All") {
                        selectedAuthor = nil
                    }
                }
                
                ForEach(authors, id: \.self) { author in
                    Button {
                        selectedAuthor = author
                    } label: {
                        Text(author.displayName ?? "Unknown Author")
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .symbolVariant(selectedAuthor == nil ? .none : .fill)
            }
        }
        .refreshableTask {
            if store.demoMode {
                vm.builds = [CiBuildRun.preview]
            } else {
                try? await vm.fetchBuilds(product.id)
            }
        }
    }
}

#Preview {
    ProductDetails(CiProduct.preview)
        .environmentObject(ValueStore())
}
