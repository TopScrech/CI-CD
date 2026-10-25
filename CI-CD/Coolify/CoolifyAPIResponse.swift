import Foundation

enum CoolifyAPIResponse {
    static func decode<Value: Decodable>(_ type: Value.Type, from data: Data, response: URLResponse) throws -> Value {
        guard let response = response as? HTTPURLResponse else {
            throw CoolifyAPIError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        guard (200..<300).contains(response.statusCode) else {
            let error = try? decoder.decode(CoolifyAPIErrorResponse.self, from: data)
            throw CoolifyAPIError.requestFailed(statusCode: response.statusCode, message: error?.message)
        }

        return try decoder.decode(type, from: data)
    }
}
