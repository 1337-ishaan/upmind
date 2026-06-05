import Foundation
import Observation
import RevenueCat

@MainActor
@Observable
final class RevenueCatManager {
    static let shared = RevenueCatManager()

    private(set) var isPremium: Bool = false
    private(set) var customerInfo: CustomerInfo?
    private(set) var availablePackages: [Package] = []
    private(set) var lastError: String?

    /// UserDefaults key for opt-in (also tracked by the Profile screen).
    private let optInKey = "Upmind.PremiumOptIn"

    private var hasConfigured = false

    private init() {}

    /// Configure the SDK. Safe to call multiple times.
    func configure() {
        guard !hasConfigured else { return }
        let apiKey = AppSecrets.revenueCatAPIKey
        guard !apiKey.isEmpty else {
            // No API key — paywall will show but purchases won't work.
            return
        }
        Purchases.logLevel = .warn
        _ = Purchases.configure(withAPIKey: apiKey)
        hasConfigured = true
        // Listen for changes
        Task { await refresh() }
    }

    /// Refresh customer info from RevenueCat. Updates `isPremium` and `customerInfo`.
    func refresh() async {
        guard hasConfigured else { return }
        do {
            let info = try await Purchases.shared.customerInfo()
            customerInfo = info
            updatePremium(from: info)
            await refreshOfferings()
        } catch {
            lastError = error.localizedDescription
        }
    }

    /// Fetch the current offering's available packages so the paywall
    /// can show real product identifiers.
    func refreshOfferings() async {
        guard hasConfigured else { return }
        do {
            let offerings = try await Purchases.shared.offerings()
            availablePackages = offerings.current?.availablePackages ?? []
        } catch {
            lastError = error.localizedDescription
        }
    }

    /// Purchase a package. Updates `isPremium` on success.
    func purchase(_ package: Package) async {
        guard hasConfigured else {
            lastError = "RevenueCat not configured"
            return
        }
        do {
            let result = try await Purchases.shared.purchase(package: package)
            customerInfo = result.customerInfo
            updatePremium(from: result.customerInfo)
        } catch {
            lastError = error.localizedDescription
        }
    }

    /// Restore previous purchases. Updates `isPremium` on success.
    func restore() async {
        guard hasConfigured else {
            lastError = "RevenueCat not configured"
            return
        }
        do {
            let info = try await Purchases.shared.restorePurchases()
            customerInfo = info
            updatePremium(from: info)
        } catch {
            lastError = error.localizedDescription
        }
    }

    /// Reset state (e.g. for tests or when signing out).
    func reset() {
        isPremium = false
        customerInfo = nil
        availablePackages = []
        lastError = nil
    }

    private func updatePremium(from info: CustomerInfo) {
        isPremium = info.entitlements[PremiumEntitlement.upmindPremium.rawValue]?.isActive == true
    }
}
