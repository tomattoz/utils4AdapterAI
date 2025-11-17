//  Created by Ivan Kh on 17.11.2025.

public struct ProviderDTO {}

extension ProviderDTO {
    public protocol Request {
        var plan: Payment.Plan { get }
        var preset: Preset.DTO { get }
        var providerID: String? { get }
    }
}
