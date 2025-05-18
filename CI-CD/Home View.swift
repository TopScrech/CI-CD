import SwiftUI

struct HomeView: View {
    var body: some View {
        List {
            Button("Test2") {
                test()
            }
        }
    }
    
    private func test() {
        Task {
            if let result = try await AppStoreAuth.fetchApps() {
                print(String(decoding: result, as: UTF8.self))
            }
        }
    }
}

#Preview {
    HomeView()
}
