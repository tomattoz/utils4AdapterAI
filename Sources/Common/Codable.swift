//  Created by Ivan Khvorostinin on 14.04.2025.

import Foundation

public extension JSONDecoder {
    func decodeX<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        do {
            return try decode(type, from: data)
        }
        catch {
            let nsError = error as NSError
            
            if nsError.domain == NSCocoaErrorDomain,
                nsError.code == 3840,
                let string = String(data: data, encoding: .utf8) {
                throw ContentError.decoding(string)
            }
            
            throw error
        }
    }    
}
