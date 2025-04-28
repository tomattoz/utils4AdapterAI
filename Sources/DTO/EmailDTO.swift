//  Created by Ivan Kh on 12.09.2024.

import Foundation

public struct EmailRegistrationRequest: Codable, StringHashable {
    public let email: String
    public let user: String
    
    public func stringHash(salt: String) -> String {
        (salt + email + user).sha256
    }
    
    public init(email: String, user: String) {
        self.email = email
        self.user = user
    }
}

public struct EmailVerificationRequest: Codable, StringHashable {
    public let email: String
    public let user: String
    public let code: String

    public func stringHash(salt: String) -> String {
        (salt + email + user + code).sha256
    }

    public init(email: String, user: String, code: String) {
        self.email = email
        self.user = user
        self.code = code
    }
}

public struct EmailVerificationResponse: Codable, StringHashable, Sendable {
    public let email: String
    public let trialActive: Bool
    public let trialSeconds: TimeInterval?

    public func stringHash(salt: String) -> String {
        (salt + email + "\(trialActive)" + "\(Int(trialSeconds ?? 0))").sha256
    }

    public init(email: String, trialActive: Bool, trialSeconds: TimeInterval?) {
        self.email = email
        self.trialActive = trialActive
        self.trialSeconds = trialSeconds
    }
}
