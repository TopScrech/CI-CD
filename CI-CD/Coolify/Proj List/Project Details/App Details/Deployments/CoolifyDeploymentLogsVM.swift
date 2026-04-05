import OSLog
import SwiftUI

@Observable
final class CoolifyDeploymentLogsVM {
    var isLoading = true
    var deployment: CoolifyDeployment?
    
    var logs: String {
        deployment?.logs ?? ""
    }
    
    var logLines: [CoolifyDeploymentLogLine] {
        parsedLogLines(from: logs)
    }
    
    func reset() {
        isLoading = true
        deployment = nil
    }
    
    func fetchDeployment(_ deploymentUUID: String, fallback: CoolifyDeployment, store: ValueStore) async {
        defer {
            isLoading = false
        }
        
        if store.coolifyDemoMode {
            deployment = fallback
            return
        }
        
        guard let account = store.coolifyAccount, account.isAuthorized else {
            deployment = fallback
            return
        }
        
        guard let url = CoolifyAPIEndpoint.deployment(deploymentUUID, domain: account.domain) else {
            deployment = fallback
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(account.apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let (data, _) = try await URLSession.shared.data(for: request)
            deployment = try decoder.decode(CoolifyDeployment.self, from: data)
        } catch {
            Logger().error("Error fetching deployment logs: \(error)")
            deployment = fallback
        }
    }
    
    private func parsedLogLines(from logs: String) -> [CoolifyDeploymentLogLine] {
        let trimmedLogs = logs.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedLogs.isEmpty else {
            return []
        }
        
        if let data = trimmedLogs.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) {
            let jsonLines = logLines(from: json)
            if !jsonLines.isEmpty {
                return jsonLines.filter { !$0.message.isEmpty }
            }
        }
        
        return trimmedLogs
            .split(whereSeparator: \.isNewline)
            .map(String.init)
            .map(CoolifyDeploymentLogLine.init)
            .filter { !$0.message.isEmpty }
    }
    
    private func logLines(from json: Any) -> [CoolifyDeploymentLogLine] {
        if let strings = json as? [String] {
            return strings.map(CoolifyDeploymentLogLine.init)
        }
        
        if let objects = json as? [[String: Any]] {
            return objects.flatMap(logLines(from:))
        }
        
        if let object = json as? [String: Any] {
            if let nested = object["logs"] {
                return logLines(from: nested)
            }
            
            if let nested = object["outputs"] {
                return logLines(from: nested)
            }
            
            return logLines(from: object)
        }
        
        return []
    }
    
    private func logLines(from object: [String: Any]) -> [CoolifyDeploymentLogLine] {
        let timestamp = object["timestamp"] as? String
            ?? object["time"] as? String
            ?? object["created_at"] as? String
            ?? object["createdAt"] as? String
        
        let message = object["message"] as? String
            ?? object["output"] as? String
            ?? object["log"] as? String
            ?? object["content"] as? String
            ?? object["line"] as? String
        
        if let message, !message.isEmpty {
            return [CoolifyDeploymentLogLine(
                timestamp: timestamp.flatMap(CoolifyDeploymentLogLine.parseDate),
                message: message
            )]
        }
        
        if let nested = object["outputs"] {
            return logLines(from: nested)
        }
        
        if let nested = object["logs"] {
            return logLines(from: nested)
        }
        
        return []
    }
}
