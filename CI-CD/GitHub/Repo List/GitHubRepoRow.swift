import ScrechKit

struct GitHubRepoRow: View {
    private let repository: GitHubRepository
    
    init(_ repository: GitHubRepository) {
        self.repository = repository
    }
    
    var body: some View {
        NavigationLink {
            GitHubRepoDetails(repository)
        } label: {
            VStack(alignment: .leading) {
                HStack {
                    Text(repository.fullName)
                        .headline()
                    
                    Spacer()
                    
                    if repository.privateRepository {
                        Image(systemName: "lock")
                            .secondary()
                    }
                }
                
                if let description = repository.description, !description.isEmpty {
                    Text(description)
                        .secondary()
                }
                
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            GitHubRepoRow(GitHubPreview.repository)
        }
    }
    .darkSchemePreferred()
}
