//  Created by Ivan Kh on 17.11.2025.

public struct FileDTO {}

public extension FileDTO {
    struct Request: Sendable, Codable, StringHashable, ProviderDTO.Request, ConversationDTO.Request {
        public let url: String
        public let plan: Payment.Plan
        public var preset: Preset.DTO
        public let providerID: String?
        public let conversation: ChatDTO.Conversation?

        public init(url: String,
                    plan: Payment.Plan,
                    preset: Preset.DTO,
                    providerID: String? = nil,
                    conversation: ChatDTO.Conversation? = nil) {
            self.url = url
            self.plan = plan
            self.preset = preset
            self.providerID = providerID
            self.conversation = conversation
        }
        
        public func stringHash(salt: String) -> String {
            let data = salt +
            url +
            plan.id +
            preset.presetID +
            (providerID ?? "")
            
            return data.sha256
        }
        
        public func copy(conversation: ChatDTO.Conversation?) -> Self {
            .init(url: url, plan: plan, preset: preset, providerID: providerID, conversation: conversation)
        }
    }
}
