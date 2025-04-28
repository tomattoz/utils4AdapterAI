//  Created by Ivan Kh on 11.09.2024.

import Foundation

public extension Preset {
    enum Provider: Codable, Equatable, Hashable, Sendable {
        case chatGPT(ChatGPT)
        case dalle(Dalle)
        case gemini(Gemini)
        case sora(Sora)

        public init(persistentID: Int16) {
            switch persistentID {
            case 0001: self = .chatGPT(.default)
            case 1001: self = .dalle(.default)
            case 2001: self = .gemini(.default)
            case 3001: self = .sora(.image)
            default: self = .chatGPT(.default)
            }
        }
        
        public init(from decoder: any Decoder) throws {
            self.init(persistentID: try Int16(from: decoder))
        }
        
        public func encode(to encoder: any Encoder) throws {
            try persistentID.encode(to: encoder)
        }
        
        public var persistentID: Int16 {
            switch self {
            case .chatGPT(let version):
                switch version { case .default: 0001 }
            case .dalle(let version):
                switch version { case .default: 1001 }
            case .gemini(let version):
                switch version { case .default: 2001 }
            case .sora(let version):
                switch version { case .image: 3001 }
            }
        }
        
        public var id: String {
            switch self {
            case .chatGPT(let version):
                switch version { case .default: "chatGPT" }
            case .dalle(let version):
                switch version { case .default: "dalle" }
            case .gemini(let version):
                switch version { case .default: "gemini" }
            case .sora(let version):
                switch version { case .image: "sora_image" }
            }
        }

        public var name: String {
            switch self {
            case .chatGPT(let version):
                switch version { case .default: return "ChatGPT" }
            case .dalle(let version):
                switch version { case .default: return "DALL·E image" }
            case .gemini(let version):
                switch version { case .default: return "Gemini" }
            case .sora(let version):
                switch version { case .image: return "Sora image" }
            }
        }

        public var isChatGPT: Bool {
            switch self {
            case .chatGPT: return true
            default: return false
            }
        }

        public var isImage: Bool {
            switch self {
            case .dalle: true
            case .sora(let sora): sora == .image
            default: false
            }
        }
    }
}

public extension Preset {
    enum ChatGPT: Codable, Sendable {
        case `default`
//        case v3_5
//        case v4_0
    }
}

public extension Preset {
    enum Dalle: Codable, Sendable {
        case `default`
//        case v2
//        case v3
    }
}

public extension Preset {
    enum Sora: Codable, Sendable {
        case image
    }
}

public extension Preset {
    enum Gemini: Codable, Sendable {
        case `default`
    }
}

