import Foundation
import OSLog
import AppStoreConnect_Swift_SDK

@Observable
final class AppVersionCardVM {
    private(set) var adpId: String?
    private(set) var errorMessage: String?
    private(set) var isProcessing = false
    private(set) var downloadURL: URL?
    
    func startProcessing(_ version: String?) async {
        guard let adpId else { return }
        
        isProcessing = true
        errorMessage = nil
        downloadURL = nil
        
        do {
            // 1. Check if ADP is already processed
            guard let statusURL = URL(string: "https://api.altstore.io/adps/\(adpId)") else {
                Logger().warning("Invalid ADP status URL")
                return
            }
            
            let (data, _) = try await URLSession.shared.data(from: statusURL)
            let statusResult = try JSONDecoder().decode(ADPStatusResponse.self, from: data)
            
            if statusResult.status == "success" {
                Logger().info("ADP already processed")
                
                try temporarySaveADP(statusResult, version: version)
                isProcessing = false
                
                return
            }
            
            // 2. If not, start processing as before
            guard let postURL = URL(string: "https://api.altstore.io/adps") else {
                Logger().warning("Invalid ADP post URL")
                return
            }
            
            var request = URLRequest(url: postURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body = try JSONEncoder().encode(
                ["adpID": adpId]
            )
            
            request.httpBody = body
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200..<300).contains(httpResponse.statusCode)
            else {
                throw URLError(.badServerResponse)
            }
            
            let result = try await pollADPStatus(
                url: statusURL,
                maxAttempts: 120,
                interval: 5
            )
            
            try temporarySaveADP(result, version: version)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
    
    private func temporarySaveADP(_ response: ADPStatusResponse, version: String?) throws {
        guard
            let urlString = response.downloadURL,
            let remoteURL = URL(string: urlString)
        else {
            throw Error.donwloadURLNotFound
        }
        
        let data = try Data(contentsOf: remoteURL)
        
        let versionString = version?
            .replacing(".", with: "_")
            .appending(".zip")
        
        let fileName = versionString ?? remoteURL.lastPathComponent
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        try data.write(to: fileURL)
        downloadURL = fileURL
    }
    
    /// Polls the ADP status endpoint up to `maxAttempts` times,
    /// waiting `interval` seconds between each
    private func pollADPStatus(url: URL, maxAttempts: Int, interval: UInt64) async throws -> ADPStatusResponse {
        for attempt in 1...maxAttempts {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(ADPStatusResponse.self, from: data)
            
            if result.status == "success" {
                return result
                
            } else if result.status == "failed" {
                throw Error.processingFailed
            }
            
            if attempt < maxAttempts {
                try await Task.sleep(for: .seconds(interval))
            }
        }
        
        throw Error.timeout
    }
    
    func getADPKey(_ notarizationId: String) async throws {
        guard let provider = try await provider() else { return }
        
        let request = APIEndpoint.v1
            .appStoreVersions
            .id(notarizationId)
            .alternativeDistributionPackage
            .get()
        
        do {
            let adpKey = try await provider.request(request).data
            adpId = adpKey.id
        } catch {
            throw error
        }
    }
}
