import Foundation

struct Preview {
    static var coolifyProj = CoolifyProject(
        id: 1,
        uuid: "demo-proj-1",
        name: "Demo Project",
        description: "Sample project",
        environments: []
    )
    
    static var coolifyApps = [
        CoolifyApp(
            uuid: "demo-app-1",
            environmentId: 1,
            repositoryProjectId: 1,
            name: "Demo App",
            description: "Sample app",
            gitRepository: "coolify/demo-app",
            gitBranch: "main",
            buildPack: "Dockerfile",
            fqdn: "https://demo.example.com",
            environmentName: "Production"
        )
    ]
    
    static var coolifyDatabases = [
        CoolifyDatabase(
            rawId: 1,
            uuid: "demo-db-1",
            environmentId: 1,
            name: "Postgres",
            description: "Primary database",
            environmentName: "Production"
        )
    ]
    
    static var coolifyDeployments = [
        CoolifyDeployment(
            id: 1,
            uuid: "demo-deploy-1",
            status: .finished,
            createdAt: "2024-01-18T10:00:00Z",
            updatedAt: "2024-01-18T10:05:00Z",
            commitMessage: "Initial deploy",
            logs: """
            2024-01-18T10:00:12Z Pulling image
            2024-01-18T10:02:31Z Building container
            2024-01-18T10:05:00Z Deployment finished successfully
            """
        ),
        CoolifyDeployment(
            id: 2,
            uuid: "demo-deploy-2",
            status: .running,
            createdAt: "2024-01-19T12:00:00Z",
            updatedAt: "2024-01-19T12:02:00Z",
            commitMessage: "Update dependencies",
            logs: """
            2024-01-19T12:00:08Z Pulling latest changes
            2024-01-19T12:01:14Z Installing dependencies
            """
        )
    ]
}
