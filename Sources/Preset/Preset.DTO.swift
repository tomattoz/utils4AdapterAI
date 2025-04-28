//  Created by Ivan Kh on 21.10.2024.

import Foundation

extension Preset {
    public struct DTO: Codable, Sendable {
        public let presetID: String
        public let presetName: String
        public let presetIcon: Icon
        public let instructions: Instructions

        public init(presetID: String, presetName: String, presetIcon: Icon, instructions: Instructions) {
            self.presetID = presetID
            self.presetName = presetName
            self.presetIcon = presetIcon
            self.instructions = instructions
        }
    }
}
