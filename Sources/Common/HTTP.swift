//  Created by Ivan Kh on 11.09.2024.

import Foundation

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
    func get<T: StringHashable & Encodable>(at path: String, data: T) throws
    -> URLRequest
    
    func post<T: StringHashable & Encodable>(at path: String, data: T) throws
    -> URLRequest
    
    func data(_ request: URLRequest) async throws
    -> (response: HTTPURLResponse, data: Data)
    
    func stream(_ request: URLRequest) async throws
    -> (response: HTTPURLResponse, stream: AsyncStream<Data>)
    
    func object<T: Decodable & StringHashable>(_ request: URLRequest) async throws
    -> (response: HTTPURLResponse, object: T)
}

public extension HTTPProvider {
    func objectUnchecked<T: Decodable>(_ request: URLRequest)
    async throws -> T {
        let response = try await data(request)
        let result: T = try JSONDecoder().decode(T.self, from: response.data)
        
        return result
    }

}
