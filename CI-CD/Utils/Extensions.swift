import AppStoreConnect_Swift_SDK

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
