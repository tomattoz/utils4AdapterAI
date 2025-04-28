//  Created by Ivan Kh on 16.10.2024.

import Foundation
import Utils9

public extension Payment {
    enum Plan: Codable, Sendable {
        case free
        case trial
        case pro
        case geekFix
        case geekMonthly
    }
}

public extension Payment.Plan {
    var id: String {
        switch self {
        case .free: "free"
        case .trial: "trial"
        case .pro: "pro"
        case .geekFix: "geekFix"
        case .geekMonthly: "geekMonthly"
        }
    }

    var groupID: String {
        switch self {
        case .free: "free"
        case .trial: "pro"
        case .pro: "pro"
        case .geekFix: "geek"
        case .geekMonthly: "geek"
        }
    }

    var displayName: String {
        switch self {
        case .free: "Free"
        case .trial: "Premium"
        case .pro: "Premium"
        case .geekFix: "Geek"
        case .geekMonthly: "Geek"
        }
    }

    var presets: Bool {
        switch self {
        case .free: true
        case .trial: true
        case .pro: true
        case .geekFix: true
        case .geekMonthly: true
        }
    }
    
    var history: Bool {
        switch self {
        case .free: true
        case .trial: true
        case .pro: true
        case .geekFix: true
        case .geekMonthly: true
        }
    }
    
    var stream: Bool {
        switch self {
        case .free: false
        case .trial: true
        case .pro: true
        case .geekFix: true
        case .geekMonthly: true
        }
    }
    
    var images: Bool {
        switch self {
        case .free: false
        case .trial: true
        case .pro: true
        case .geekFix: true
        case .geekMonthly: true
        }
    }

    var hasTrial: Bool {
        switch self {
        case .free: false
        case .trial: true
        case .pro: true
        case .geekFix: false
        case .geekMonthly: false
        }
    }
    
    var registrationTrialActive: Bool {
        switch self {
        case .free: false
        case .trial: true
        case .pro: false
        case .geekFix: false
        case .geekMonthly: false
        }
    }
    
    var model: Payment.Model {
        switch self {
        case .free: Self.modelFree.value
        case .trial: Self.modelTrial.value
        case .pro: Self.modelPro.value
        case .geekFix: Self.modelGeekFix.value
        case .geekMonthly: Self.modelGeekMonthly.value
        }
    }
}

public extension Payment.Plan {
    var isGeek: Bool {
        self == .geekFix || self == .geekMonthly
    }
}

private extension Payment.Plan {
    static let modelFree = LockedVar(Payment.Model(plan: .free, price: "0.00"))
    static let modelTrial = LockedVar(Payment.Model(plan: .trial, price: ""))
    static let modelPro = LockedVar(Payment.Model(plan: .pro, price: ""))
    static let modelGeekFix = LockedVar(Payment.Model(plan: .geekFix, price: ""))
    static let modelGeekMonthly = LockedVar(Payment.Model(plan: .geekMonthly, price: ""))
}
