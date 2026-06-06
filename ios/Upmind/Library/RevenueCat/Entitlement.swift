import Foundation

enum PremiumEntitlement: String, Sendable {
    case upmindPremium = "upmind_premium"
}

enum PremiumPlan: String, CaseIterable, Sendable, Identifiable {
    case weekly
    case yearly

    var id: String { rawValue }

    /// Display price as it appears in the paywall. Hardcoded for v1; in v2
    /// these come from the actual StoreKit product via RevenueCat.
    var displayPrice: String {
        switch self {
        case .weekly: return "$9.99 / week"
        case .yearly: return "$39.99 / year"
        }
    }

    /// Discount badge for the yearly plan.
    var discountBadge: String? {
        switch self {
        case .yearly: return "Save 92%"
        case .weekly: return nil
        }
    }

    /// RevenueCat `Package` `packageType` we expect to back this plan.
    /// The default identifier for a weekly package is `$rc_weekly` and
    /// for a yearly package is `$rc_annual` (RevenueCat's "annual" is
    /// the standard 1-year tier).
    var packageTypeIdentifier: String {
        switch self {
        case .weekly: return "$rc_weekly"
        case .yearly: return "$rc_annual"
        }
    }
}
