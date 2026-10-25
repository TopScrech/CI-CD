import Foundation
import Network

enum CoolifyTransport {
    static func data(for request: URLRequest, account: CoolifyAccountSnapshot) async throws -> (Data, URLResponse) {
        guard account.proxyEnabled else {
            return try await URLSession.shared.data(for: request)
        }
        guard let credentials = try CoolifyProxyKeychain.load(accountID: account.id) else {
            throw CoolifyProxyError.missingCredentials
        }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.proxyConfigurations = [try credentials.configuration()]
        let session = URLSession(configuration: configuration)
        defer { session.finishTasksAndInvalidate() }
        return try await session.data(for: request)
    }
}
