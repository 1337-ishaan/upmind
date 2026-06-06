import XCTest
import SwiftUI
@testable import Upmind

final class ThemeTests: XCTestCase {

    func testThemeProvidesTokensForBothSchemes() {
        let light = Theme.tokens(for: .light)
        let dark = Theme.tokens(for: .dark)
        XCTAssertEqual(light.surfaceBase, ColorTokens.light.surfaceBase)
        XCTAssertEqual(dark.surfaceBase, ColorTokens.dark.surfaceBase)
    }

    func testThemeResolvesToDarkInDefaultAppearance() {
        // Upmind spec is dark-first; default appearance is dark.
        XCTAssertEqual(Theme.defaultScheme, .dark)
    }
}
