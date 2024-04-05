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

public class HTTPClient {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    public init() {}

    public func request<
        Response: Decodable,
        Body: Encodable
    >(
        _ method: HTTPMethod,
        _ url: URL,
        body: Body? = nil
    ) async throws -> Response {
        let (data, _) = try await sendRequest(
            method,
            url,
            body: body
        )
        return try decode(data)
    }

    func sendRequest<Body: Encodable>(
        _ method: HTTPMethod,
        _ url: URL,
        body: Body? = nil
    ) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: url)
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
