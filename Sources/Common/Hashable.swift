//  Created by Ivan Kh on 05.09.2024.

import Foundation

public protocol StringHashable {
    func stringHash(salt: String) -> String
}
