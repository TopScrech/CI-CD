import ScrechKit
import AppStoreConnect_Swift_SDK
import OSLog

struct BuildDetailsToolbar: ToolbarContent {
    @Environment(ConnectWebBuildVM.self) private var webBuildVM
    @Environment(BuildVM.self) private var vm
    @EnvironmentObject private var store: ValueStore

    let build: CiBuildRun

    var body: some ToolbarContent {
        if webBuildVM.isLoading {
            ToolbarItem(placement: .primaryAction) {
                ProgressView()
                    .accessibilityLabel("Loading build environment")
            }
            .preferredToolbarAxis(.verticalPreferred)
        }

        if !store.connectDemoMode, let workflow = build.relationships?.workflow?.data {
            ToolbarItem(placement: .primaryAction) {
                Menu("Build actions", systemImage: "ellipsis") {
                    AsyncButton("Rebuild", systemImage: "hammer") {
                        do {
                            try await vm.startRebuild(of: build.id, in: workflow.id, store: store)
                        } catch {
                            Logger().error("Failed to start rebuild: \(error)")
                        }
                    }

                    AsyncButton("Rebuild clean", systemImage: "hammer") {
                        do {
                            try await vm.startRebuild(of: build.id, in: workflow.id, clean: true, store: store)
                        } catch {
                            Logger().error("Failed to start clean rebuild: \(error)")
                        }
                    }
                }
            }
        }
    }
}
