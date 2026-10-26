import SwiftUI
import AppStoreConnect_Swift_SDK

@Observable
final class WorkflowEnvironmentVM {
    var xcodeVersionID: String?
    var macOSVersionID: String?
    private(set) var xcodeVersions: [CiXcodeVersion] = []
    private(set) var macOSVersions: [CiMacOsVersion] = []
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    var errorMessage: String?

    private var originalXcodeVersionID: String?
    private var originalMacOSVersionID: String?

    init(_ workflow: CiWorkflow) {
        let xcodeID = workflow.relationships?.xcodeVersion?.data?.id
        let macOSID = workflow.relationships?.macOsVersion?.data?.id
        xcodeVersionID = xcodeID
        macOSVersionID = macOSID
        originalXcodeVersionID = xcodeID
        originalMacOSVersionID = macOSID
    }

    var compatibleMacOSVersions: [CiMacOsVersion] {
        let supportedIDs = Set(xcodeVersions.first { $0.id == xcodeVersionID }?
            .relationships?.macOsVersions?.data?.map(\.id) ?? [])
        return macOSVersions.filter { supportedIDs.contains($0.id) }
    }

    var xcodeOptions: [WorkflowVersionOption] {
        xcodeVersions.map {
            WorkflowVersionOption(id: $0.id, name: $0.attributes?.name ?? $0.id, build: $0.attributes?.version)
        }
    }

    var macOSOptions: [WorkflowVersionOption] {
        macOSVersions.map {
            WorkflowVersionOption(id: $0.id, name: $0.attributes?.name ?? $0.id, build: $0.attributes?.version)
        }
    }

    var compatibleMacOSOptions: [WorkflowVersionOption] {
        let compatibleIDs = Set(compatibleMacOSVersions.map(\.id))
        return macOSOptions.filter { compatibleIDs.contains($0.id) }
    }

    var xcodeAliasCurrentVersion: String? {
        xcodeOptions.first { $0.id == xcodeVersionID }?.currentVersion(in: xcodeOptions)
    }

    var macOSAliasCurrentVersion: String? {
        compatibleMacOSOptions.first { $0.id == macOSVersionID }?.currentVersion(in: macOSOptions)
    }

    var hasChanges: Bool {
        xcodeVersionID != originalXcodeVersionID || macOSVersionID != originalMacOSVersionID
    }

    var canSave: Bool {
        !hasChanges || (!isLoading && errorMessage == nil &&
            xcodeVersions.contains { $0.id == xcodeVersionID } &&
            compatibleMacOSVersions.contains { $0.id == macOSVersionID })
    }

    func selectCompatibleMacOSVersion() {
        guard !compatibleMacOSVersions.contains(where: { $0.id == macOSVersionID }) else { return }
        macOSVersionID = compatibleMacOSVersions.first?.id
    }

    func refresh(from workflow: CiWorkflow) {
        let wasEdited = hasChanges
        let xcodeID = workflow.relationships?.xcodeVersion?.data?.id
        let macOSID = workflow.relationships?.macOsVersion?.data?.id
        if !wasEdited {
            xcodeVersionID = xcodeID
            macOSVersionID = macOSID
        }
        originalXcodeVersionID = xcodeID
        originalMacOSVersionID = macOSID
    }

    func load(store: ValueStore) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
            hasLoaded = true
        }

        do {
            if store.connectDemoMode {
                xcodeVersions = [.init(
                    type: .ciXcodeVersions,
                    id: "demo-xcode",
                    attributes: .init(name: "Demo Xcode"),
                    relationships: .init(macOsVersions: .init(data: [
                        .init(type: .ciMacOsVersions, id: "demo-macos")
                    ]))
                )]
                macOSVersions = [.init(type: .ciMacOsVersions, id: "demo-macos", attributes: .init(name: "Demo macOS"))]
                return
            }

            guard let provider = try await provider(store: store) else {
                throw URLError(.userAuthenticationRequired)
            }

            var xcodeVersions: [CiXcodeVersion] = []
            var macOSVersions: [CiMacOsVersion] = []
            let request = APIEndpoint.v1.ciXcodeVersions.get(parameters: .init(
                fieldsCiXcodeVersions: [.name, .version, .macOsVersions],
                fieldsCiMacOsVersions: [.name, .version],
                limit: 200,
                include: [.macOsVersions],
                limitMacOsVersions: 50
            ))
            for try await page in provider.paged(request) {
                xcodeVersions.append(contentsOf: page.data)
            }
            for try await page in provider.paged(APIEndpoint.v1.ciMacOsVersions.get(parameters: .init(limit: 200))) {
                macOSVersions.append(contentsOf: page.data)
            }
            try Task.checkCancellation()
            self.xcodeVersions = xcodeVersions
            self.macOSVersions = macOSVersions
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
