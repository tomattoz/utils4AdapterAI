//  Created by Ivan Kh on 04.10.2024.

import Foundation
import Utils9

public enum ContentError: Error, Codable, DisplayError, AdditionalInfoError {
    case empty
    case unsupported
    case modelUnsupportedByPlan(String)
    case decoding(String)

    public var displayDescription: String {
        switch self {
        case .empty:
            "The response is empty"
        case .unsupported:
            "Unsupported"
        case .modelUnsupportedByPlan(let model):
            "Model \(model) is unsupported by your plan"
        case .decoding:
            "Failed to decode message"
        }
    }
    
    public var additionalInfo: [String : String] {
        switch self {
        case .decoding(let src): [ "src": src ]
        default: [:]
        }
    }
}

public enum HTTPError: Error, Codable, DisplayError {
    case invalidHash
    case unknown(statusCode: UInt)
    
    public var displayDescription: String {
        switch self {
        case .unknown(let statusCode):
            return "Unknown error occured with status code \(statusCode)"
        case .invalidHash:
            return "Input data was changed during delivery. Please try again or contact us at support@aispot.club"
        }
    }
}

public enum RegistrationError: Error, Codable {
    case emailNotFound
    case userNotFound
    case codeInvalid
    case trialExpired
    
    public var resetTrial: Bool {
        self == .trialExpired || self == .userNotFound
    }
}

public struct GenericError: LocalizedError, CustomStringConvertible, Codable {
    public let inner: String
    public let description: String
    
    public init(_ inner: Error) {
        self.inner = String(describing: inner)
        self.description = inner.friendlyDescription
    }
    
    public var errorDescription: String? {
        description
    }
}

public struct OpenAIAPIError: Error, Codable, DisplayError {
    public let message: String
    public let type: String?
    public let param: String?
    public let code: String?
    
    public init(message: String, type: String?, param: String?, code: String?) {
        self.message = message
        self.type = type
        self.param = param
        self.code = code
    }
    
    public var displayDescription: String {
        message
    }
}

public enum OpenAIError: Error, Codable, DisplayError {
    case apiKeyIsEmpty
   
    public var displayDescription: String {
        switch self {
        case .apiKeyIsEmpty:
            return "Please open application Settings and enter OpenAI API key"
        }
    }
}

public enum ServerError: Codable {
    case http(HTTPError)
    case registration(RegistrationError)
    case content(ContentError)
    case openai(OpenAIAPIError)
    case openai2(OpenAIError)
    case generic(GenericError)
}
