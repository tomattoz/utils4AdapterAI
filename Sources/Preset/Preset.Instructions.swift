//  Created by Ivan Kh on 21.10.2024.

import Foundation

public extension Preset {
    struct Instructions: Codable, Sendable {
        public let provider: Provider
        public let text: String

        public init(provider: Provider, text: String) {
            self.provider = provider
            self.text = text
        }
    }
}

public extension Preset.Instructions {
    func copy(_ text: String) -> Self {
        .init(provider: provider, text: text)
    }

    func copy(_ provider: Preset.Provider) -> Self {
        .init(provider: provider, text: text)
    }

    static func chatGPT(text: String) -> Self {
        .init(provider: .chatGPT(.default), text: text)
    }
}
