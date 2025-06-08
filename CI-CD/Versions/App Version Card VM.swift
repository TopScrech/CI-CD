import Foundation
import AppStoreConnect_Swift_SDK

@Observable
final class AppVersionCardVM {
    var adpId: String?
    var errorMessage: String?
    var isProcessing = false
    var downloadUrl: URL?
    
    func startProcessing(_ version: String?) async {
        guard let adpId else {
            return
        }
        
        isProcessing = true
        errorMessage = nil
        downloadUrl = nil
        
        do {
            // 1. Check if ADP is already processed
            guard let statusUrl = URL(string: "https://api.altstore.io/adps/\(adpId)") else {
                print("⛔️ Invalid status URL")
                return
            }
            
            let (statusData, _) = try await URLSession.shared.data(from: statusUrl)
            let statusResult = try JSONDecoder().decode(ADPStatusResponse.self, from: statusData)
            
            if statusResult.status == "success" {
                print("Already processed")
                
                try temporarySaveADP(statusResult, version: version)
                isProcessing = false
                
                return
            }
            
            // 2. If not, start processing as before
            guard let postUrl = URL(string: "https://api.altstore.io/adps") else {
                print("⛔️ Invalid URL")
                return
            }
            
            var request = URLRequest(url: postUrl)
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
                url: statusUrl,
                maxAttempts: 120,
                interval: 5
            )
            
            try temporarySaveADP(result, version: version)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
    
    private func temporarySaveADP(
        _ response: ADPStatusResponse,
        version: String?
    ) throws {
        
        guard
            let urlString = response.downloadURL,
            let remoteUrl = URL(string: urlString)
        else {
            throw Error.donwloadUrlNotFound
        }
        
        let data = try Data(contentsOf: remoteUrl)
        
        let versionString = version?
            .replacingOccurrences(of: ".", with: "_")
            .appending(".zip")
        
        let fileName = versionString ?? remoteUrl.lastPathComponent
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileUrl = tempDir.appendingPathComponent(fileName)
        
        try data.write(to: fileUrl)
        downloadUrl = fileUrl
    }
    
    /// Polls the ADP status endpoint up to `maxAttempts` times,
    /// waiting `interval` seconds between each
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
                throw Error.processingFailed
            }
            
            if attempt < maxAttempts {
                try await Task.sleep(nanoseconds: interval * 1_000_000_000)
            }
        }
        
        throw Error.timeout
    }
    
    func getADPKey(_ notarizationId: String) async throws {
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
            throw error
        }
    }
}
