import Foundation

struct GitHubAPIClient {
    let account: GitHubAccountSnapshot
    
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    func repositories() async throws -> [GitHubRepository] {
        let repositories = try await request([GitHubRepository].self, path: "/user/repos", queryItems: [
            URLQueryItem(name: "sort", value: "pushed"),
            URLQueryItem(name: "per_page", value: "100")
        ])
        
        guard !account.owner.isEmpty else {
            return repositories
        }
        
        return repositories.filter {
            $0.ownerName.localizedStandardContains(account.owner)
        }
    }
    
    func workflows(owner: String, repository: String) async throws -> [GitHubWorkflow] {
        let response = try await request(
            GitHubWorkflowResponse.self,
            path: "/repos/\(owner)/\(repository)/actions/workflows",
            queryItems: [
                URLQueryItem(name: "per_page", value: "100")
            ]
        )
        return response.workflows
    }
    
    func workflowRuns(owner: String, repository: String) async throws -> [GitHubWorkflowRun] {
        let response = try await request(
            GitHubWorkflowRunResponse.self,
            path: "/repos/\(owner)/\(repository)/actions/runs",
            queryItems: [
                URLQueryItem(name: "per_page", value: "30")
            ]
        )
        return response.workflowRuns
    }
    
    func dispatchWorkflow(owner: String, repository: String, workflowID: Int, ref: String) async throws {
        let body = GitHubWorkflowDispatchRequest(ref: ref)
        _ = try await request(
            EmptyResponse.self,
            path: "/repos/\(owner)/\(repository)/actions/workflows/\(workflowID)/dispatches",
            method: "POST",
            body: body,
            acceptedStatusCodes: [204]
        )
    }
    
    func rerun(owner: String, repository: String, runID: Int) async throws {
        _ = try await request(
            EmptyResponse.self,
            path: "/repos/\(owner)/\(repository)/actions/runs/\(runID)/rerun",
            method: "POST",
            acceptedStatusCodes: [201]
        )
    }
    
    func cancel(owner: String, repository: String, runID: Int) async throws {
        _ = try await request(
            EmptyResponse.self,
            path: "/repos/\(owner)/\(repository)/actions/runs/\(runID)/cancel",
            method: "POST",
            acceptedStatusCodes: [202]
        )
    }
    
    private func request<Response: Decodable>(
        _ response: Response.Type,
        path: String,
        queryItems: [URLQueryItem] = [],
        method: String = "GET",
        body: (some Encodable)? = Optional<EmptyRequest>.none,
        acceptedStatusCodes: Set<Int> = Set(200..<300)
    ) async throws -> Response {
        var request = URLRequest(url: try url(path: path, queryItems: queryItems))
        request.httpMethod = method
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(account.token)", forHTTPHeaderField: "Authorization")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        
        if let body {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw GitHubAPIError.invalidResponse
        }
        
        guard acceptedStatusCodes.contains(httpResponse.statusCode) else {
            let message = try? decoder.decode(GitHubErrorResponse.self, from: data).message
            throw GitHubAPIError.requestFailed(statusCode: httpResponse.statusCode, message: message)
        }
        
        let responseData = data.isEmpty ? Data("{}".utf8) : data
        return try decoder.decode(Response.self, from: responseData)
    }
    
    private func url(path: String, queryItems: [URLQueryItem]) throws -> URL {
        guard let baseURL = URL(string: account.apiBaseURL) else {
            throw GitHubAPIError.invalidBaseURL
        }
        
        guard var components = URLComponents(url: baseURL.appending(path: path), resolvingAgainstBaseURL: false) else {
            throw GitHubAPIError.invalidBaseURL
        }
        
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        
        guard let url = components.url else {
            throw GitHubAPIError.invalidBaseURL
        }
        
        return url
    }
}

enum GitHubAPIError: LocalizedError {
    case invalidBaseURL
    case invalidResponse
    case requestFailed(statusCode: Int, message: String?)
    
    var errorDescription: String? {
        switch self {
        case .invalidBaseURL:
            String(localized: "The GitHub API URL is invalid")
        case .invalidResponse:
            String(localized: "GitHub returned an invalid response")
        case .requestFailed(let statusCode, let message):
            if let message {
                String(localized: "GitHub request failed with status \(statusCode): \(message)")
            } else {
                String(localized: "GitHub request failed with status \(statusCode)")
            }
        }
    }
}

private struct GitHubWorkflowDispatchRequest: Encodable {
    let ref: String
}

private struct GitHubErrorResponse: Decodable {
    let message: String
}

private struct EmptyRequest: Encodable {}

private struct EmptyResponse: Decodable {}
