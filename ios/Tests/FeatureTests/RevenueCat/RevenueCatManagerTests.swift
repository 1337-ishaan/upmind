import XCTest
@testable import Upmind

@MainActor
final class RevenueCatManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        RevenueCatManager.shared.reset()
    }

    func testPremiumPlanDisplayPrices() {
        XCTAssertEqual(PremiumPlan.weekly.displayPrice, "$9.99 / week")
        XCTAssertEqual(PremiumPlan.yearly.displayPrice, "$39.99 / year")
    }

    func testYearlyHasDiscountBadge() {
        XCTAssertNotNil(PremiumPlan.yearly.discountBadge)
        XCTAssertNil(PremiumPlan.weekly.discountBadge)
    }

    func testNoConfigKeepsIsPremiumFalse() {
        XCTAssertFalse(RevenueCatManager.shared.isPremium)
    }

    func testResetClearsState() {
        RevenueCatManager.shared.reset()
        XCTAssertFalse(RevenueCatManager.shared.isPremium)
        XCTAssertNil(RevenueCatManager.shared.customerInfo)
    }
}
