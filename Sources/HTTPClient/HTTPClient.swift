import Foundation

public enum HTTPMethod {
    case get
    case query
    case post
    case put
    case patch
    case delete
    case head
    case options
    case connect
    case trace

    var description: String {
        switch self {
        case .get: "GET"
        case .query: "QUERY"
        case .post: "POST"
        case .put: "PUT"
        case .patch: "PATCH"
        case .delete: "DELETE"
        case .head: "HEAD"
        case .options: "OPTIONS"
        case .connect: "CONNECT"
        case .trace: "TRACE"
        }
    }
}

public enum HTTPClientError: Error {
    case requestFailed(Error)
    case decodingError(Error)
    case encodingError(Error)
}

public struct HTTPClientHeaders {
    let referer: String?
    let userAgent: String?

    public init(
        referer: String? = nil,
        userAgent: String? = nil
    ) {
        self.referer = referer
        self.userAgent = userAgent
    }
}

public class HTTPClient {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let defaultHeaders: HTTPClientHeaders

    public init(
        defaultHeaders: HTTPClientHeaders = HTTPClientHeaders()
    ) {
        self.defaultHeaders = defaultHeaders
    }

    public func request<
        Response: Decodable,
        Body: Encodable
    >(
        _ method: HTTPMethod,
        _ url: URL,
        body: Body? = nil,
        includeDefaultHeaders: Bool = true
    ) async throws -> Response {
        let (data, _) = try await sendRequest(
            method,
            url,
            body: body,
            includeDefaultHeaders: includeDefaultHeaders
        )
        return try decode(data)
    }

    func sendRequest<Body: Encodable>(
        _ method: HTTPMethod,
        _ url: URL,
        body: Body?,
        includeDefaultHeaders: Bool
    ) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: url)
        addDefaultHeaders(to: &request)
        request.httpMethod = method.description
        request.httpBody = if let body {
            try encode(body)
        } else {
            Data?.none
        }

        do {
            let (data, response) = try await URLSession.shared.data(
                for: request
            )
            return (data, response)
        } catch {
            // TODO: More specific error requests based on what URLSession threw
            throw HTTPClientError.requestFailed(error)
        }
    }

    func addDefaultHeaders(to request: inout URLRequest) {
        if let referer = defaultHeaders.referer {
            request.addValue(referer, forHTTPHeaderField: "Referer")
        }

        if let userAgent = defaultHeaders.userAgent {
            request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        }
    }

    func encode<T: Encodable>(_ value: T) throws -> Data {
        do {
            return try encoder.encode(value)
        } catch {
            throw HTTPClientError.encodingError(error)
        }
    }

    func decode<T: Decodable>(_ data: Data) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw HTTPClientError.decodingError(error)
        }
    }
}
