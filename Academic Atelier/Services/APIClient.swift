import Foundation

enum APIError: LocalizedError {
    case invalidRequest
    case missingToken
    case invalidResponse
    case missingData
    case unauthorized(message: String)
    case server(message: String, statusCode: Int)
    case transport(Error)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "The request could not be prepared."
        case .missingToken:
            return "You need to sign in again."
        case .invalidResponse:
            return "The server response was invalid."
        case .missingData:
            return "The server returned an empty response."
        case let .unauthorized(message):
            return message
        case let .server(message, _):
            return message
        case let .transport(error):
            return error.localizedDescription
        case let .decoding(error):
            return "Failed to decode server response: \(error.localizedDescription)"
        }
    }
}

struct APIClient {
    private let configuration: APIConfiguration
    private let session: URLSession
    private let tokenStore: KeychainService
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        configuration: APIConfiguration = APIConfiguration(),
        session: URLSession = .shared,
        tokenStore: KeychainService = .shared
    ) {
        self.configuration = configuration
        self.session = session
        self.tokenStore = tokenStore
    }

    func send<Response: Decodable>(
        path: String,
        method: String = "GET",
        requiresAuth: Bool = false
    ) async throws -> Response {
        let request = try makeRequest(
            path: path,
            method: method,
            body: Optional<EmptyRequest>.none,
            requiresAuth: requiresAuth
        )

        return try await execute(request, responseType: Response.self)
    }

    func send<Response: Decodable, Body: Encodable>(
        path: String,
        method: String,
        body: Body,
        requiresAuth: Bool = false
    ) async throws -> Response {
        let request = try makeRequest(
            path: path,
            method: method,
            body: body,
            requiresAuth: requiresAuth
        )

        return try await execute(request, responseType: Response.self)
    }

    private func makeRequest<Body: Encodable>(
        path: String,
        method: String,
        body: Body?,
        requiresAuth: Bool
    ) throws -> URLRequest {
        let sanitizedPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        let url = configuration.baseURL.appending(path: sanitizedPath)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if requiresAuth {
            guard let token = tokenStore.loadToken(), !token.isEmpty else {
                throw APIError.missingToken
            }

            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            request.httpBody = try encoder.encode(body)
        }

        return request
    }

    private func execute<Response: Decodable>(
        _ request: URLRequest,
        responseType: Response.Type
    ) async throws -> Response {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.transport(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if (200...299).contains(httpResponse.statusCode) {
            do {
                let envelope = try decoder.decode(APIResponse<Response>.self, from: data)
                logResponse(
                    request: request,
                    statusCode: httpResponse.statusCode,
                    backendMessage: envelope.message
                )
                guard let payload = envelope.data else {
                    throw APIError.missingData
                }
                return payload
            } catch let error as APIError {
                throw error
            } catch {
                throw APIError.decoding(error)
            }
        }

        let message = decodeErrorMessage(from: data) ?? HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
        logResponse(
            request: request,
            statusCode: httpResponse.statusCode,
            backendMessage: message
        )

        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized(message: message)
        }

        throw APIError.server(message: message, statusCode: httpResponse.statusCode)
    }

    private func decodeErrorMessage(from data: Data) -> String? {
        guard !data.isEmpty else { return nil }
        return (try? decoder.decode(APIErrorResponse.self, from: data))?.message
    }

    private func logResponse(
        request: URLRequest,
        statusCode: Int,
        backendMessage: String
    ) {
#if DEBUG
        let url = request.url?.absoluteString ?? "unknown-url"
        print("[API] URL:", url)
        print("[API] Status:", statusCode)
        print("[API] Message:", backendMessage)
#endif
    }
}
