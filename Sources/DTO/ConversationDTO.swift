//  Created by Ivan Kh on 17.11.2025.

public struct ConversationDTO {}

extension ConversationDTO {
    public protocol Request {
        var conversation: ChatDTO.Conversation? { get }
        func copy(conversation: ChatDTO.Conversation?) -> Self
    }
}
