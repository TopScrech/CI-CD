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
            commitMessage: "Initial deploy"
        ),
        CoolifyDeployment(
            id: 2,
            uuid: "demo-deploy-2",
            status: .running,
            createdAt: "2024-01-19T12:00:00Z",
            updatedAt: "2024-01-19T12:02:00Z",
            commitMessage: "Update dependencies"
        )
    ]
}
