//  Created by Ivan Kh on 19.02.2026.

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Foundation
import Utils9

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
