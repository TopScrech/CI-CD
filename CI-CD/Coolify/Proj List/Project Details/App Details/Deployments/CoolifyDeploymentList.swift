import SwiftUI

struct CoolifyDeploymentList: View {
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
                    CoolifyDeploymentCard($0)
                }
            }
        }
    }
}

#Preview {
    List {
        CoolifyDeploymentList()
    }
    .darkSchemePreferred()
    .environment(CoolifyAppDetailsVM())
}
