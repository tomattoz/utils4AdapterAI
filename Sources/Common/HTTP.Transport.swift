//  Created by Ivan Kh on 19.02.2026.

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Foundation
import Utils9

public protocol HTTPTransport {
    func data(_ request: URLRequest) async throws
    -> (response: HTTPURLResponse, data: Data)
    
    func stream(_ request: URLRequest) async throws
    -> (response: HTTPURLResponse, stream: AsyncThrowingStream<Data, Error>)
}

open class HTTPTransportErrorHandler: HTTPTransport {
    private let inner: HTTPTransport
    
    public init(_ inner: HTTPTransport) {
        self.inner = inner
    }
    
    public func data(_ request: URLRequest) async throws
    -> (response: HTTPURLResponse, data: Data) {
        let result = try await inner.data(request)
        try await handleError(result.response) { result.data }
        return result
    }
    
    public func stream(_ request: URLRequest) async throws
    -> (response: HTTPURLResponse, stream: AsyncThrowingStream<Data, any Error>) {
        let result = try await inner.stream(request)
        try await handleError(result.response) {
            try await result.stream.reduce(into: Data()) {
                $0.append($1)
            }
        }
        return result
    }
    
    open func handleError(_ response: HTTPURLResponse, data: Data) throws {
        assertionFailure() // For override
    }
    
    private func handleError(_ response: HTTPURLResponse, data: () async throws -> Data) async throws {
        guard !response.statusCodeOK else { return }
        try handleError(response, data: try await data())
    }
}

public class HTTPTransportQueued: HTTPTransport {
    private let queue: AsyncThrowingQueue
    private let inner: HTTPTransport
    
    public init(queue: AsyncThrowingQueue, inner: HTTPTransport) {
        self.queue = queue
        self.inner = inner
    }
    
    public func data(_ request: URLRequest) async throws
    -> (response: HTTPURLResponse, data: Data) {
        try await queue.exec {
            try await inner.data(request)
        }
    }
    
    public func stream(_ request: URLRequest) async throws
    -> (response: HTTPURLResponse, stream: AsyncThrowingStream<Data, Error>) {
        try await queue.exec {
            try await inner.stream(request)
        }
    }
}

public class HTTPTransportServerErrorHandler: HTTPTransportErrorHandler {
    public override func handleError(_ response: HTTPURLResponse, data: Data) throws {
        var serverError: ServerError?
             
        do {
            serverError = try JSONDecoder().decode(ServerError.self, from: data)
        }
        catch {
            try throwErrorForStatusCode(response)
        }
        
        if let serverError {
            switch serverError {
            case .http(let error): throw error
            case .registration(let error): throw error
            case .content(let error): throw error
            case .openai(let error): throw error
            case .openai2(let error): throw error
            case .generic(let error): throw error
            }
        }
        else {
            try throwErrorForStatusCode(response)
        }
    }
    
    private func throwErrorForStatusCode(_ response: HTTPURLResponse) throws {
        if response.statusCode == 504 {
            throw Error9.Timeout()
        }
        else {
            throw StringError(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))
        }
    }
}

public struct HTTPTransportStub: HTTPTransport {
    public init() {}
    
    public func data(_ request: URLRequest) async throws -> (response: HTTPURLResponse, data: Data) {
        throw Error9.unsupported
    }
    
    public func stream(_ request: URLRequest) async throws -> (response: HTTPURLResponse, stream: AsyncThrowingStream<Data, Error>) {
        throw Error9.unsupported
    }
}

#if !os(Linux)
@available(macOS 12.0, *)
open class HTTPTransportURLSession: HTTPTransport {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func data(_ request: URLRequest) async throws
    -> (response: HTTPURLResponse, data: Data) {
        let result = try await session.bytes(for: request)
        guard let response = result.1 as? HTTPURLResponse else { throw Error9.unsupported }
        return (response: response, data: try await result.0.readAll)
    }
    
    public func stream(_ request: URLRequest) async throws
    -> (response: HTTPURLResponse, stream: AsyncThrowingStream<Data, Error>) {
        let result = try await session.bytes(for: request)
        guard let response = result.1 as? HTTPURLResponse else { throw Error9.unsupported }
        return (response: response, stream: result.0.stream)
    }
}
#endif

#if !os(Linux)
@available(macOS 12.0, *)
private actor StreamReader {
    private let input: URLSession.AsyncBytes
    private let continuation: AsyncThrowingStream<Data, Error>.Continuation
    private static let chunkSize = 1024
    private var buffer = Data(capacity: chunkSize)

    init(input: URLSession.AsyncBytes,
         output: AsyncThrowingStream<Data, Error>.Continuation) {
        self.input = input
        self.continuation = output
    }
    
    func read() async {
        do {
            for try await byte in input {
                process(byte)
            }

            if !buffer.isEmpty {
                continuation.yield(buffer)
            }

            continuation.finish()
        } catch {
            continuation.finish(throwing: error)
        }
    }
    
    @inlinable func process(_ byte: UInt8) {
        buffer.append(byte)
        
        if buffer.count >= Self.chunkSize {
            let chunk = buffer
            continuation.yield(chunk)
            buffer.removeAll(keepingCapacity: true)
        }
    }
}
#endif

#if !os(Linux)
@available(macOS 12.0, *)
private extension URLSession.AsyncBytes {
    var stream: AsyncThrowingStream<Data, Error> {
        .init(bufferingPolicy: .unbounded) { continuation in
            Task {
                await StreamReader(input: self, output: continuation).read()
            }
        }
    }
    
    var readAll: Data {
        get async throws {
            var buffer = Data()

            for try await byte in self {
                buffer.append(byte)
            }
            
            return buffer
        }
    }
}
#endif
