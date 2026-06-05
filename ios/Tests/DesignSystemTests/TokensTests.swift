import XCTest
@testable import Upmind

final class TokensTests: XCTestCase {

    func testSpacingScaleHasExpectedValues() {
        XCTAssertEqual(Spacing.xxs, 4)
        XCTAssertEqual(Spacing.xs, 8)
        XCTAssertEqual(Spacing.sm, 12)
        XCTAssertEqual(Spacing.md, 16)
        XCTAssertEqual(Spacing.lg, 24)
        XCTAssertEqual(Spacing.xl, 32)
        XCTAssertEqual(Spacing.xxl, 48)
    }

    func testRadiusScaleHasExpectedValues() {
        XCTAssertEqual(Radius.sm, 8)
        XCTAssertEqual(Radius.md, 14)
        XCTAssertEqual(Radius.lg, 22)
        XCTAssertEqual(Radius.pill, 999)
    }

    func testMinTapTargetIsHigCompliant() {
        XCTAssertGreaterThanOrEqual(MinTapTarget.size, 44)
    }
}
