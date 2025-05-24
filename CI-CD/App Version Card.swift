import SwiftUI
import AppStoreConnect_Swift_SDK

struct AppVersionCard: View {
    private let version: AppStoreVersion
    
    init(_ version: AppStoreVersion) {
        self.version = version
    }
    
    @State private var adpId: String?
    @State private var isProcessing = false
    @State private var downloadURL: URL?
    @State private var errorMessage: String?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(version.attributes?.versionString ?? "-")
                    .title3(.semibold)
                
                if let adpId {
                    Text(adpId)
                        .footnote()
                        .foregroundStyle(.secondary)
                }
                
                if let downloadURL {
                    Link("Download", destination: downloadURL)
                        .footnote(.semibold)
                        .foregroundStyle(.blue)
                }
                
                if let errorMessage {
                    Text(errorMessage)
                        .footnote()
                        .foregroundStyle(.red)
                }
            }
            
            Spacer()
            
            if let adpId, !isProcessing, downloadURL == nil {
                Button {
                    Task { await startProcessing(adpId) }
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .semibold()
                }
            } else if isProcessing {
                ProgressView()
            }
        }
        .foregroundStyle(.primary)
        .task {
            if adpId == nil {
                try? await getADPKey(version.id)
            }
        }
    }
    
    private func startProcessing(_ adpId: String) async {
        isProcessing = true
        errorMessage = nil
        downloadURL = nil
        
        do {
            guard let postURL = URL(string: "https://api.altstore.io/adps") else {
                print("⛔️ Invalid URL")
                return
            }
            
            var request = URLRequest(url: postURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body = try JSONEncoder().encode(["adpID": adpId])
            request.httpBody = body
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            guard let url = URL(string: "https://api.altstore.io/adps/\(adpId)") else {
                print("⛔️ Invalid URL")
                return
            }
            
            let result = try await pollADPStatus(url: url, maxAttempts: 120, interval: 5)
            
            if let urlString = result.downloadURL, let url = URL(string: urlString) {
                downloadURL = url
            } else {
                throw NSError(domain: "ADP", code: 2, userInfo: [NSLocalizedDescriptionKey: "No download URL found"])
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
    
    /// Polls the ADP status endpoint up to `maxAttempts` times, waiting `interval` seconds between each.
    private func pollADPStatus(
        url: URL,
        maxAttempts: Int,
        interval: UInt64
    ) async throws -> ADPStatusResponse {
        for attempt in 1...maxAttempts {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(ADPStatusResponse.self, from: data)
            
            if result.status == "success" {
                return result
            } else if result.status == "failed" {
                throw NSError(
                    domain: "ADP",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Processing failed"]
                )
            }
            
            if attempt < maxAttempts {
                try await Task.sleep(nanoseconds: interval * 1_000_000_000)
            }
        }
        
        throw NSError(
            domain: "ADP",
            code: 3,
            userInfo: [NSLocalizedDescriptionKey: "Timed out waiting for download URL"]
        )
    }
    
    private func getADPKey(_ notarizationId: String) async throws {
        guard let provider = try await provider() else {
            return
        }
        
        let request = APIEndpoint.v1
            .appStoreVersions
            .id(notarizationId)
            .alternativeDistributionPackage
            .get()
        
        do {
            let adpKey = try await provider.request(request).data
            adpId = adpKey.id
        } catch {
            print(error)
            throw error
        }
    }
}

private struct ADPStatusResponse: Decodable {
    let status: String
    let downloadURL: String?
}

#Preview {
    List {
        AppVersionCard(AppStoreVersion.preview)
    }
    .darkSchemePreferred()
}
