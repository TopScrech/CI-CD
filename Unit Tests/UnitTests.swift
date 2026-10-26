import Foundation
import Testing

struct UnitTests {
    @Test(arguments: ["https://coolify.example.com", "https://other.example.com:8443"])
    func usedConfiguredDomain(domain: String) {
        #expect(CoolifyAPIEndpoint.fetchProjects(domain: domain)?.absoluteString == "\(domain)/api/v1/projects")
        #expect(CoolifyAPIEndpoint.fetchApps(domain: domain)?.absoluteString == "\(domain)/api/v1/applications")
        #expect(CoolifyAPIEndpoint.fetchDatabases(domain: domain)?.absoluteString == "\(domain)/api/v1/databases")
    }

    @Test func decodedApps() throws {
        let data = Data(#"[{"uuid":"app-id","environment_id":2,"name":"API","repository_project_id":null,"git_repository":"example/api","build_pack":"dockerfile"}]"#.utf8)
        let apps = try decoder().decode([CoolifyApp].self, from: data)
        let app = try #require(apps.first)

        #expect(app.uuid == "app-id")
        #expect(app.environmentId == 2)
        #expect(app.name == "API")
        #expect(app.gitRepoURL?.absoluteString == "https://github.com/example/api")
        #expect(app.buildPack == "dockerfile")
    }

    @Test func decodedDatabases() throws {
        let data = Data(#"[{"id":7,"environment_id":2,"name":"Postgres","description":"Primary database"}]"#.utf8)
        let databases = try decoder().decode([CoolifyDatabase].self, from: data)
        let database = try #require(databases.first)

        #expect(database.id == "7")
        #expect(database.environmentId == 2)
        #expect(database.name == "Postgres")
        #expect(database.description == "Primary database")
    }

    private func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
