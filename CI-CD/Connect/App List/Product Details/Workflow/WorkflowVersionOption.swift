import Foundation

struct WorkflowVersionOption: Identifiable {
    let id: String
    let name: String
    let build: String?

    var isAlias: Bool {
        name == "Latest Release" || name == "Latest Beta or Release"
    }

    func currentVersion(in versions: [WorkflowVersionOption]) -> String? {
        guard isAlias, let build, !build.isEmpty else { return nil }
        guard let version = versions.first(where: { !$0.isAlias && $0.build == build }) else {
            return build
        }
        return "\(version.name) (\(build))"
    }
}
