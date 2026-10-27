import Foundation
import ASC

extension APIProvider: @retroactive @unchecked Sendable {}

extension CiGitUser: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(displayName)
        hasher.combine(avatarURL)
    }
    
    public static func == (lhs: CiGitUser, rhs: CiGitUser) -> Bool {
        lhs.displayName == rhs.displayName &&
        lhs.avatarURL == rhs.avatarURL
    }
}

extension CiAction: @retroactive Identifiable {
    public var id: UUID {
        UUID()
    }
}
