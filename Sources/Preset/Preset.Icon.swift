//  Created by Ivan Kh on 11.09.2024.

import Foundation

public extension Preset {
    enum Icon: Equatable, Codable, Sendable {
        case onboard(name: String)
        case system(name: String)
    }
}
