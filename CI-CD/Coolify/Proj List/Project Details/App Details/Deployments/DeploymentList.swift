import SwiftUI

struct DeploymentList: View {
    @Environment(CoolifyAppDetailsVM.self) private var vm
    
    var body: some View {
        if vm.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            if vm.deployments.isEmpty {
                ContentUnavailableView("No deployments yet", systemImage: "shippingbox")
            } else {
                ForEach(vm.deployments) {
                    DeploymentCard($0)
                }
            }
        }
    }
}

#Preview {
    List {
        DeploymentList()
    }
    .darkSchemePreferred()
    .environment(CoolifyAppDetailsVM())
}
