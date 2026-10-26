import SwiftUI

struct CoolifyProjList: View {
    @State private var vm = CoolifyProjListVM()
    @EnvironmentObject private var store: ValueStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @State private var sheetAuth = false
    
    var body: some View {
        List {
            if store.coolifyDemoMode || store.coolifyAuthorized {
                if let errorMessage = vm.errorMessage {
                    ContentUnavailableView {
                        Label("Couldn’t load projects", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(errorMessage)
                    } actions: {
                        Button("Retry", systemImage: "arrow.clockwise") {
                            store.bumpRefreshToken(for: .coolify)
                        }

                        Button("Account settings", systemImage: "gear") {
                            sheetAuth = true
                        }
                    }
                }

                ForEach(vm.projects) {
                    CoolifyProjCard($0)
                }
            } else {
                ProjectListCredentialsUnavailableView(serviceName: "Coolify") {
                    sheetAuth = true
                }
            }
        }
        .environment(vm)
        .animation(reduceMotion ? nil : .default, value: vm.projects)
        .refreshable {
            await vm.fetchProjects(store: store)
        }
        .task(id: store.coolifyRefreshToken) {
            await vm.fetchProjects(store: store)
        }
        .onChange(of: store.coolifyAccount) {
            store.bumpRefreshToken(for: .coolify)
        }
        .sheet($sheetAuth) {
            CoolifyAuthView()
        }
    }
}

#Preview {
    CoolifyProjList()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
