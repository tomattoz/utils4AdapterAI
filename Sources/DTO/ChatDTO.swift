//  Created by Ivan Kh on 11.09.2024.

import Foundation
import Utils9Crypto

public struct ChatDTO {}

public extension ChatDTO {
    enum Message: Codable, Sendable {
        case system(content: String)
        case user(content: String)
        case assistant(content: String)
        
        public var content: String {
            switch self {
            case .system(let content): content
            case .user(let content): content
            case .assistant(let content): content
            }
        }
    }
}

public extension ChatDTO {
    struct Conversation: Codable, Hashable, Sendable {
        public let ID: String
        public let targetMessageID: String
        
        public init(ID: String, targetMessageID: String) {
            self.ID = ID
            self.targetMessageID = targetMessageID
        }
        
        public init?(ID: String?, targetMessageID: String?) {
            guard let ID, let targetMessageID else {
                return nil
            }
            
            self.ID = ID
            self.targetMessageID = targetMessageID
        }
    }
}

public extension ChatDTO {
    struct Request: Sendable, Codable, StringHashable {
        public let user: String
        public let email: String?
        public let plan: Payment.Plan
        public let preset: Preset.DTO
        public let messages: [ChatDTO.Message]
        public let providerID: String?
        public let conversation: ChatDTO.Conversation?
        
        public func stringHash(salt: String) -> String {
            let data = salt +
            plan.id +
            user +
            (email ?? "") +
            preset.instructions.provider.id +
            "\(messages.last?.content.count ?? 0)"
            
            return data.sha256
        }
        
        public init(user: String,
                    email: String?,
                    plan: Payment.Plan,
                    preset: Preset.DTO,
                    messages: [ChatDTO.Message],
                    provider: String?,
                    conversation: ChatDTO.Conversation? = nil) {
            self.user = user
            self.email = email
            self.plan = plan
            self.preset = preset
            self.messages = messages
            self.providerID = provider
            self.conversation = conversation
        }
        
        public func copy(conversation: ChatDTO.Conversation?) -> Self {
            .init(user: user,
                  email: email,
                  plan: plan,
                  preset: preset,
                  messages: messages,
                  provider: providerID,
                  conversation: conversation)
        }

        public func copy(messages: [ChatDTO.Message]) -> Self {
            .init(user: user,
                  email: email,
                  plan: plan,
                  preset: preset,
                  messages: messages,
                  provider: providerID,
                  conversation: conversation)
        }
    }
}

public extension ChatDTO {
    struct Response: Codable, Sendable {
        public let message: String
        public let provider: String
        public let conversation: ChatDTO.Conversation?
        
        public init(message: String, provider: String, conversation: ChatDTO.Conversation?) {
            self.message = message
            self.provider = provider
            self.conversation = conversation
        }
    }
}

public extension ChatDTO {
    struct PartialResponse: Codable, Sendable {
        public let message: String
        public let provider: String?
        public let conversation: ChatDTO.Conversation?
        
        public init(message: String, provider: String?, conversation: ChatDTO.Conversation?) {
            self.message = message
            self.provider = provider
            self.conversation = conversation
        }
    }
}

public extension ChatDTO.PartialResponse {
    static let header = "5f011571-e475-4e4d-a740-026db97af11b"
    static let headerData = Self.header.data(using: .utf8)!
}
