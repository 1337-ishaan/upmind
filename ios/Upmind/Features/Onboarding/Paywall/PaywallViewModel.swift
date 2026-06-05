import Foundation
import Observation
import RevenueCat

@MainActor
@Observable
final class PaywallViewModel {
    var selectedPlan: PremiumPlan = .yearly
    var isPurchasing: Bool = false
    var lastError: String?

    let manager: RevenueCatManager

    init(manager: RevenueCatManager = .shared) {
        self.manager = manager
    }

    /// Look up the package for the currently selected plan. Falls back
    /// to any package whose identifier contains the plan's raw value
    /// when an exact match isn't found.
    private func package(for plan: PremiumPlan) -> Package? {
        let pkgs = manager.availablePackages
        if let exact = pkgs.first(where: { $0.identifier == plan.packageTypeIdentifier }) {
            return exact
        }
        return pkgs.first { $0.identifier.contains(plan.rawValue) }
    }

    func purchase() async -> Bool {
        isPurchasing = true
        defer { isPurchasing = false }
        let target = selectedPlan
        guard let pkg = package(for: target) else {
            lastError = "Package \(target.rawValue) not available. Configure RevenueCat."
            return false
        }
        await manager.purchase(pkg)
        return manager.isPremium
    }

    func restore() async {
        isPurchasing = true
        defer { isPurchasing = false }
        await manager.restore()
    }
}
