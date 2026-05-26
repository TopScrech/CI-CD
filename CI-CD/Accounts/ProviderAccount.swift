import SwiftUI
import SwiftData

enum AccountProvider: String, CaseIterable, Identifiable, Codable {
    case connect, coolify, github

    var id: String { rawValue }

    var title: String {
        switch self {
        case .connect: String(localized: "Connect")
        case .coolify: String(localized: "Coolify")
        case .github: String(localized: "GitHub Actions")
        }
    }
    
    var logoAssetName: ImageResource {
        switch self {
        case .connect: .appStoreConnect
        case .coolify: .coolify
        case .github: .gitHub
        }
    }
    
    var homeViewTab: HomeViewTab {
        switch self {
        case .connect: .connect
        case .coolify: .coolify
        case .github: .github
        }
    }
}

@Model
final class ProviderAccount {
    var id: UUID = UUID()
    var providerRawValue: String = AccountProvider.connect.rawValue
    var name: String = ""
    var issuerID: String = ""
    var privateKey: String = ""
    var privateKeyID: String = ""
    var coolifyDomain: String = "https://coolify.example.com"
    var coolifyAPIKey: String = ""
    var githubAPIBaseURL: String = "https://api.github.com"
    var githubToken: String = ""
    var githubOwner: String = ""
    var demoMode: Bool = false
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    init(
        id: UUID = UUID(),
        provider: AccountProvider,
        name: String = "",
        issuerID: String = "",
        privateKey: String = "",
        privateKeyID: String = "",
        coolifyDomain: String = "https://coolify.example.com",
        coolifyAPIKey: String = "",
        githubAPIBaseURL: String = "https://api.github.com",
        githubToken: String = "",
        githubOwner: String = "",
        demoMode: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.providerRawValue = provider.rawValue
        self.name = name
        self.issuerID = issuerID
        self.privateKey = privateKey
        self.privateKeyID = privateKeyID
        self.coolifyDomain = coolifyDomain
        self.coolifyAPIKey = coolifyAPIKey
        self.githubAPIBaseURL = githubAPIBaseURL
        self.githubToken = githubToken
        self.githubOwner = githubOwner
        self.demoMode = demoMode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension ProviderAccount {
    var provider: AccountProvider {
        get { AccountProvider(rawValue: providerRawValue) ?? .connect }
        set { providerRawValue = newValue.rawValue }
    }

    var effectiveName: String {
        if !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name
        }

        switch provider {
        case .connect:
            return issuerID.isEmpty ? String(localized: "Connect account") : issuerID
            
        case .coolify:
            let endpoint = coolifyDomain
                .replacing("https://", with: "")
                .replacing("http://", with: "")
            
            return endpoint.isEmpty ? String(localized: "Coolify account") : endpoint
            
        case .github:
            return githubOwner.isEmpty ? String(localized: "GitHub account") : githubOwner
        }
    }

    var isConnectAuthorized: Bool {
        !issuerID.isEmpty && !privateKey.isEmpty && !privateKeyID.isEmpty
    }

    var isCoolifyAuthorized: Bool {
        !coolifyDomain.isEmpty && !coolifyAPIKey.isEmpty
    }
    
    var isGitHubAuthorized: Bool {
        !githubAPIBaseURL.isEmpty && !githubToken.isEmpty
    }

    func touch() {
        updatedAt = Date()
    }
}
