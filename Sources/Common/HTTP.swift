//  Created by Ivan Kh on 11.09.2024.

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Foundation
import Utils9

public extension String {
    static let httpHeaderContentType = "Content-Type"
    static let httpHeaderContentHash = "Content-Hash"
}

public enum HTTPMethod: String, Codable, Sendable, Equatable, Identifiable {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
    case head = "HEAD"
    case options = "OPTIONS"
    case trace = "TRACE"
    case patch = "PATCH"
    case connect = "CONNECT"
    
    public var id: String {
        rawValue
    }
}

public protocol HTTPProvider {
    var transport: HTTPTransport { get }
    
    func get<T: StringHashable & Encodable>(at path: String, data: T) throws
    -> URLRequest
    
    func post<T: StringHashable & Encodable>(at path: String, data: T) throws
    -> URLRequest
    
    func object<T: Decodable & StringHashable>(_ request: URLRequest) async throws
    -> (response: HTTPURLResponse, object: T)
}

public extension HTTPProvider {
    func objectUnchecked<T: Decodable>(_ request: URLRequest)
    async throws -> T {
        let response = try await transport.data(request)
        let result: T = try JSONDecoder().decode(T.self, from: response.data)
        
        return result
    }
    
    func data(_ request: URLRequest) async throws
    -> (response: HTTPURLResponse, data: Data) {
        try await transport.data(request)
    }
    
    func stream(_ request: URLRequest) async throws
    -> (response: HTTPURLResponse, stream: AsyncThrowingStream<Data, Error>) {
        try await transport.stream(request)
    }
}

public final class HTTPProviderDefault: HTTPProvider {
    @AnyVar private var urlString: String
    private let salt: String
    public let transport: HTTPTransport

    public init(transport: HTTPTransport, url: AnyVar<String>, salt: String) {
        self._urlString = url
        self.salt = salt
        self.transport = transport
    }

    public func get<T: StringHashable & Encodable>(at path: String, data: T) throws
    -> URLRequest {
        try request(at: path, data: data, method: .get)
    }
    
    public func post<T: StringHashable & Encodable>(at path: String, data: T) throws
    -> URLRequest {
        try request(at: path, data: data, method: .post)
    }
    
    public func object<T: Decodable & StringHashable>(_ request: URLRequest) async throws
    -> (response: HTTPURLResponse, object: T) {
        let result = try await transport.data(request)
        let response = result.response
        let object: T = try JSONDecoder().decode(T.self, from: result.data)
        guard object.stringHash(salt: salt) == response.value(forHTTPHeaderField: .httpHeaderContentHash)
        else { throw HTTPError.invalidHash }
        
        return (response: response, object: object)
    }
}

private extension HTTPProviderDefault {
    func request(for path: String) -> URLRequest {
        let url = URL(string: urlString)!
        return .init(url: url.appendingPathComponent(path))
    }
    
    func request<T: StringHashable & Encodable>(at path: String,
                                                data: T,
                                                method: Utils9AIAdapter.HTTPMethod) throws
    -> URLRequest {
        var request = request(for: path)
        let requestData = try JSONEncoder().encode(data)
        
        request.setValue("application/json", forHTTPHeaderField: .httpHeaderContentType)
        request.setValue(data.stringHash(salt: salt), forHTTPHeaderField: .httpHeaderContentHash)
        request.httpBody = requestData
        request.httpMethod = method.rawValue
        
        return request
    }
}

public extension HTTPURLResponse {
    var statusCodeOK: Bool {
        statusCode >= 200 && statusCode < 300
    }
}

public struct HTTPProviderStub: HTTPProvider {
    public var transport: HTTPTransport = HTTPTransportStub()
    
    public init() {}
    
    public func get<T: StringHashable & Encodable>(at path: String, data: T) throws -> URLRequest {
        throw Error9.unsupported
    }
    
    public func post<T: StringHashable & Encodable>(at path: String, data: T) throws -> URLRequest {
        throw Error9.unsupported
    }
    
    public func object<T: Decodable & StringHashable>(_ request: URLRequest) async throws -> (response: HTTPURLResponse, object: T) {
        throw Error9.unsupported
    }
}
