import Foundation
import AppStoreConnect_Swift_SDK

@Observable
final class AppVersionCardVM {
    var adpId: String?
    var errorMessage: String?
    var isProcessing = false
    var downloadUrl: URL?
    
    func startProcessing() async {
        guard let adpId else {
            return
        }
        
        isProcessing = true
        errorMessage = nil
        downloadUrl = nil
        
        do {
            // 1. Check if ADP is already processed
            guard let statusURL = URL(string: "https://api.altstore.io/adps/\(adpId)") else {
                print("⛔️ Invalid status URL")
                return
            }
            
            let (statusData, _) = try await URLSession.shared.data(from: statusURL)
            let statusResult = try JSONDecoder().decode(ADPStatusResponse.self, from: statusData)
            
            if statusResult.status == "success" {
                //            if statusResult.status == "success", let urlString = statusResult.downloadURL {
                print("Already processed")
                
                //                downloadUrl = urlString
                try temporarySaveADP(statusResult)
                
                //                safariCover = true
                isProcessing = false
                return
            }
            
            // 2. If not, start processing as before
            guard let postURL = URL(string: "https://api.altstore.io/adps") else {
                print("⛔️ Invalid URL")
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
            
            try temporarySaveADP(result)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
    
    private func temporarySaveADP(_ response: ADPStatusResponse) throws {
        guard
            let urlString = response.downloadURL,
            let remoteURL = URL(string: urlString)
        else {
            throw NSError(
                domain: "ADP",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "No download URL found"]
            )
        }
        
        let data = try Data(contentsOf: remoteURL)
        
        let fm = FileManager.default
        let tempDirectory = fm.temporaryDirectory
        let originalFileName = remoteURL.lastPathComponent
        let fileURL = tempDirectory.appendingPathComponent(originalFileName)
        
        try data.write(to: fileURL)
        
        downloadUrl = fileURL
    }
    
    /// Polls the ADP status endpoint up to `maxAttempts` times, waiting `interval` seconds between each
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
                    userInfo: [
                        NSLocalizedDescriptionKey: "Processing failed"
                    ]
                )
            }
            
            if attempt < maxAttempts {
                try await Task.sleep(nanoseconds: interval * 1_000_000_000)
            }
        }
        
        throw NSError(
            domain: "ADP",
            code: 3,
            userInfo: [
                NSLocalizedDescriptionKey: "Timed out waiting for download URL"
            ]
        )
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
