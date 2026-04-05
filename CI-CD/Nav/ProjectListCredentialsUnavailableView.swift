import SwiftUI

struct ProjectListCredentialsUnavailableView: View {
    let serviceName: String
    let action: () -> Void
    
    var body: some View {
        ContentUnavailableView {
            Label("Credentials missing", systemImage: "key.fill")
        } description: {
            Text("Add your \(serviceName) credentials to load projects")
        } actions: {
            Button("Provide credentials", action: action)
        }
    }
}

#Preview {
    ProjectListCredentialsUnavailableView(serviceName: "Coolify") {}
        .darkSchemePreferred()
}
