import XCTest
@testable import Upmind

final class EngineTests: XCTestCase {

    func testGameIdHasExactly42Cases() {
        XCTAssertEqual(GameId.allCases.count, 42)
    }

    func testGameIdRoundTripsThroughRawValue() {
        for id in GameId.allCases {
            XCTAssertEqual(GameId(rawValue: id.rawValue), id)
        }
    }

    func testPremiumGameIdsAreCorrect() {
        let premium: Set<GameId> = [.trailmix, .rulefind, .setshift, .planning, .inhibit]
        XCTAssertEqual(Set(GameId.allCases.filter { $0.isPremium }), premium)
    }

    func testEngineErrorProvidesMessages() {
        XCTAssertNotNil(EngineError.unknownGame("foo").errorDescription)
        XCTAssertNotNil(EngineError.duplicateAnswer.errorDescription)
    }
}
