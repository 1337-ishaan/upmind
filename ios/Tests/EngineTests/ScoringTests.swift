import XCTest
@testable import Upmind

final class ScoringTests: XCTestCase {

    func testAllCorrectGivesScore100() {
        let score = Scoring.score(
            correct: 20,
            total: 20,
            rtMedianMs: 500,
            rtStddevMs: 100,
            drifts: 0
        )
        XCTAssertEqual(score.score, 100)
    }

    func testHalfCorrectGivesScore50() {
        let score = Scoring.score(
            correct: 10,
            total: 20,
            rtMedianMs: 500,
            rtStddevMs: 100,
            drifts: 0
        )
        XCTAssertEqual(score.score, 50)
    }

    func testZeroCorrectGivesScore0() {
        let score = Scoring.score(
            correct: 0,
            total: 20,
            rtMedianMs: 500,
            rtStddevMs: 100,
            drifts: 0
        )
        XCTAssertEqual(score.score, 0)
    }

    func testEmptySessionGivesScore0() {
        let score = Scoring.score(
            correct: 0,
            total: 0,
            rtMedianMs: 0,
            rtStddevMs: 0,
            drifts: 0
        )
        XCTAssertEqual(score.score, 0)
        XCTAssertEqual(score.accuracy, 0)
    }

    func testAccuracyIsRatio() {
        let score = Scoring.score(
            correct: 7,
            total: 10,
            rtMedianMs: 500,
            rtStddevMs: 100,
            drifts: 0
        )
        XCTAssertEqual(score.accuracy, 0.7, accuracy: 0.0001)
    }

    func testDriftCountIsPassedThrough() {
        let score = Scoring.score(
            correct: 10,
            total: 20,
            rtMedianMs: 500,
            rtStddevMs: 100,
            drifts: 3
        )
        XCTAssertEqual(score.drifts, 3)
    }
}
