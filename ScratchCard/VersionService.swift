import Foundation

protocol VersionService: Sendable {
    func iosVersion(code: String) async throws -> String
}

struct APIVersionService: VersionService {
    private struct Response: Decodable {
        let ios: String
    }

    static func request(code: String) throws -> URLRequest {
        guard var components = URLComponents(string: Constants.API.versionURL) else {
            throw URLError(.badURL)
        }

        components.queryItems = [URLQueryItem(name: Constants.API.codeParameter, value: code)]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = Constants.API.versionMethod

        return request
    }

    func iosVersion(code: String) async throws -> String {
        let request = try Self.request(code: code)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
            (200..<300).contains(statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(Response.self, from: data).ios
    }
}
