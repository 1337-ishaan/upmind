import XCTest
import SwiftUI
@testable import Upmind

@MainActor
final class GameCatalogViewModelTests: XCTestCase {

    /// Selecting a construct should narrow the catalog to games tagged
    /// with that construct. The total count drops below `Games.all.count`
    /// and every returned game matches the filter.
    func testFilteringByConstructReducesResults() {
        let vm = GameCatalogViewModel()
        let attentionCount = Games.all.filter { $0.construct == .attention }.count

        XCTAssertGreaterThan(attentionCount, 0, "Sanity: catalog must have attention games")
        XCTAssertEqual(vm.filteredGames.count, Games.all.count,
                       "Default selection is nil (All), so all games should be visible")

        vm.selectedConstruct = .attention
        let filtered = vm.filteredGames

        XCTAssertEqual(filtered.count, attentionCount,
                       "Filtering by attention should return only attention games")
        XCTAssertTrue(filtered.allSatisfy { $0.construct == .attention },
                      "Every filtered game should have construct == .attention")
    }

    /// Typing into the search field should match against both the game's
    /// name and its description, case-insensitive, trimming whitespace.
    func testSearchFiltersByNameAndDescription() {
        let vm = GameCatalogViewModel()

        // "Stroop" is the name of one game. The description is "Name the
        // ink color" — that doesn't contain "stroop", so a name hit must
        // be enough.
        vm.searchText = "stroop"
        XCTAssertEqual(vm.filteredGames.count, 1,
                       "Search by name should match exactly one game")
        XCTAssertEqual(vm.filteredGames.first?.id, .stroop)

        // "ink" appears only in the description of Stroop, not in any
        // other game's name or description.
        vm.searchText = "ink"
        let inkMatches = vm.filteredGames
        XCTAssertEqual(inkMatches.count, 1, "Search by description text should match exactly one game")
        XCTAssertEqual(inkMatches.first?.id, .stroop)

        // Whitespace is trimmed; mixed case is fine.
        vm.searchText = "  STROOP  "
        XCTAssertEqual(vm.filteredGames.count, 1, "Search should trim whitespace and ignore case")

        // Empty / whitespace-only string returns all games.
        vm.searchText = "   "
        XCTAssertEqual(vm.filteredGames.count, Games.all.count,
                       "Whitespace-only search should not filter anything")
    }
}
