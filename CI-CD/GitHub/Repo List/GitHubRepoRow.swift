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
            HStack {
                VStack(alignment: .leading) {
                    Text(repository.fullName)
                        .headline()
                    
                    if let description = repository.description, !description.isEmpty {
                        Text(description)
                            .secondary()
                    }
                    
                }
                
                Spacer()
                
                if repository.privateRepository {
                    Image(systemName: "lock")
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
