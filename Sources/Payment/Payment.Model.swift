//  Created by Ivan Kh on 14.08.2023.

import Foundation

public extension Payment {
    class Model: Codable {
        public let plan: Payment.Plan
        public var price: String

        init(plan: Payment.Plan, price: String) {
            self.plan = plan
            self.price = price
        }
    }
}
