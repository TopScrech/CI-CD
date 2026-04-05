import SwiftUI

struct CoolifyDeploymentLogsView: View {
    @EnvironmentObject private var store: ValueStore
    
    @State private var vm = CoolifyDeploymentLogsVM()
    
    private let deployment: CoolifyDeployment
    
    init(_ deployment: CoolifyDeployment) {
        self.deployment = deployment
    }
    
    var body: some View {
        Group {
            if vm.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if vm.logLines.isEmpty {
                ContentUnavailableView("No logs available", systemImage: "doc.text.magnifyingglass")
            } else {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(vm.logLines) { line in
                            HStack(alignment: .top) {
                                Text(line.timeText ?? "--:--")
                                    .secondary()
                                    .frame(width: 44, alignment: .leading)
                                
                                Text(line.message)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .font(.footnote.monospaced())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                }
                .padding()
            }
        }
        .navigationTitle("Deployment logs")
        .navSubtitle(deployment.uuid ?? "")
        .task {
            vm.reset()
            await load()
        }
        .onChange(of: store.coolifyAccount?.id) {
            Task {
                vm.reset()
                await load()
            }
        }
        .onChange(of: store.coolifyDemoMode) {
            Task {
                vm.reset()
                await load()
            }
        }
        .onChange(of: store.coolifyRefreshToken) {
            Task {
                vm.reset()
                await load()
            }
        }
    }
    
    private func load() async {
        guard let uuid = deployment.uuid else {
            vm.deployment = deployment
            vm.isLoading = false
            return
        }
        
        await vm.fetchDeployment(uuid, fallback: deployment, store: store)
    }
}

#Preview {
    NavigationStack {
        CoolifyDeploymentLogsView(Preview.coolifyDeployments[0])
    }
    .environmentObject(ValueStore())
}
