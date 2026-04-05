import Foundation
import SwiftData

enum AccountProvider: String, CaseIterable, Identifiable, Codable {
    case connect, coolify

    var id: String { rawValue }

    var title: String {
        switch self {
        case .connect: String(localized: "Connect")
        case .coolify: String(localized: "Coolify")
        }
    }

    var systemImage: String {
        switch self {
        case .connect:
            "app.dashed"
        case .coolify:
            "globe"
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
        }
    }

    var isConnectAuthorized: Bool {
        !issuerID.isEmpty && !privateKey.isEmpty && !privateKeyID.isEmpty
    }

    var isCoolifyAuthorized: Bool {
        !coolifyDomain.isEmpty && !coolifyAPIKey.isEmpty
    }

    func touch() {
        updatedAt = Date()
    }
}
