import Foundation
import Network

struct CoolifyProxyCredentials: Codable, Equatable {
    var url = ""
    var username = ""
    var password = ""

    init(url: String = "", username: String = "", password: String = "") {
        self.url = url
        self.username = username
        self.password = password
    }

    init(from decoder: any Decoder) throws {
        let values = try decoder.singleValueContainer().decode([String: String].self)
        guard let url = values["url"], let password = values["password"] else {
            throw CoolifyProxyError.missingCredentials
        }
        self.url = url
        self.password = password
        username = values["username"] ?? ""
    }

    func configuration() throws -> ProxyConfiguration {
        guard let components = URLComponents(string: url.trimmingCharacters(in: .whitespacesAndNewlines)),
              components.scheme?.lowercased() == "https",
              let host = components.host, !host.isEmpty,
              components.user == nil, components.password == nil,
              components.query == nil, components.fragment == nil,
              components.path.isEmpty || components.path == "/",
              let portNumber = UInt16(exactly: components.port ?? 443),
              portNumber > 0, let port = NWEndpoint.Port(rawValue: portNumber) else {
            throw CoolifyProxyError.invalidURL
        }
        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CoolifyProxyError.missingUsername
        }
        guard !password.isEmpty else { throw CoolifyProxyError.missingPassword }

        var proxy = ProxyConfiguration(
            httpCONNECTProxy: .hostPort(host: .init(host), port: port),
            tlsOptions: NWProtocolTLS.Options()
        )
        proxy.applyCredential(username: username, password: password)
        proxy.allowFailover = false
        return proxy
    }
}
