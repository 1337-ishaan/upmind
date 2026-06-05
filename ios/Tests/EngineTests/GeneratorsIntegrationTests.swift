import XCTest
@testable import Upmind

/// Verifies that every registered generator produces a structurally valid
/// trial and is deterministic. Parameterized over all 42 `GameId` values.
///
/// These tests are the safety net for Round 4: any of the 42 generators
/// that produces a malformed trial — wrong template shape, multiple
/// "correct" choices, out-of-range grid indices, etc. — fails one of
/// these checks loudly with the offending `GameId` in the assertion message.
final class GeneratorsIntegrationTests: XCTestCase {

    func testEveryGeneratorProducesAValidTrial() {
        for id in GameId.allCases {
            guard let gen = Generators.lookup(id) else {
                XCTFail("No generator for \(id)")
                continue
            }
            let trial = gen.makeTrial(index: 0, difficulty: 1)
            XCTAssertEqual(trial.id.uuidString.count, 36,
                           "\(id) produced a trial with a non-UUID id")
            XCTAssertEqual(trial.index, 0, "\(id) reported wrong trial index")
            XCTAssertEqual(trial.difficulty, 1, "\(id) reported wrong difficulty")
        }
    }

    func testEveryGeneratorIsDeterministic() {
        for id in GameId.allCases {
            guard let gen = Generators.lookup(id) else { continue }
            let a = gen.makeTrial(index: 5, difficulty: 1)
            let b = gen.makeTrial(index: 5, difficulty: 1)
            // Trial UUIDs are fresh per call, so we can't compare the whole
            // trial. Compare the structural payload (template + content)
            // instead by ignoring `id`.
            XCTAssertTrue(trialsAreStructurallyEqual(a, b),
                          "\(id) is not deterministic at index 5")
        }
    }

    func testEveryChoiceTemplateHasExactlyOneCorrect() {
        for id in GameId.allCases {
            guard let gen = Generators.lookup(id) else { continue }
            for i in 0..<3 {
                let trial = gen.makeTrial(index: i, difficulty: 1)
                switch trial {
                case .choice(let t):
                    let correct = t.choices.filter(\.correct).count
                    XCTAssertEqual(correct, 1,
                                   "\(id) trial \(i) has \(correct) correct choices, expected 1")
                case .recall(let t):
                    let correct = t.choices.filter(\.correct).count
                    XCTAssertEqual(correct, 1,
                                   "\(id) trial \(i) has \(correct) correct choices, expected 1")
                default:
                    break  // non-choice templates don't carry a per-choice correctness flag
                }
            }
        }
    }

    func testEveryReactionTrialRespectsMinMaxDelay() {
        for id in GameId.allCases {
            guard let gen = Generators.lookup(id) else { continue }
            for i in 0..<5 {
                let trial = gen.makeTrial(index: i, difficulty: 1)
                if case .reaction(let t) = trial {
                    XCTAssertGreaterThanOrEqual(t.minDelayMs, 0,
                                                "\(id) trial \(i) has negative minDelay")
                    XCTAssertGreaterThanOrEqual(t.maxDelayMs, t.minDelayMs,
                                                "\(id) trial \(i) has max < min")
                }
            }
        }
    }

    func testEveryGridTrialHasValidDimensions() {
        for id in GameId.allCases {
            guard let gen = Generators.lookup(id) else { continue }
            for i in 0..<3 {
                let trial = gen.makeTrial(index: i, difficulty: 1)
                if case .grid(let t) = trial {
                    XCTAssertGreaterThan(t.rows, 0, "\(id) trial \(i) has 0 rows")
                    XCTAssertGreaterThan(t.cols, 0, "\(id) trial \(i) has 0 cols")
                    XCTAssertEqual(t.cells.count, t.rows,
                                   "\(id) trial \(i) cells row count mismatch")
                    for row in t.cells {
                        XCTAssertEqual(row.count, t.cols,
                                       "\(id) trial \(i) cells col count mismatch")
                    }
                    XCTAssertGreaterThanOrEqual(t.answer.row, 0,
                                                "\(id) trial \(i) answer.row negative")
                    XCTAssertLessThan(t.answer.row, t.rows,
                                      "\(id) trial \(i) answer.row >= rows")
                    XCTAssertGreaterThanOrEqual(t.answer.col, 0,
                                                "\(id) trial \(i) answer.col negative")
                    XCTAssertLessThan(t.answer.col, t.cols,
                                      "\(id) trial \(i) answer.col >= cols")
                }
            }
        }
    }

    // MARK: - helpers

    /// Compares two trials ignoring their generated UUIDs. Returns true if
    /// the template and all content fields match.
    private func trialsAreStructurallyEqual(_ a: Trial, _ b: Trial) -> Bool {
        switch (a, b) {
        case (.choice(let x), .choice(let y)):
            return x.index == y.index && x.difficulty == y.difficulty
                && x.prompt == y.prompt && x.choices == y.choices && x.mode == y.mode
        case (.reaction(let x), .reaction(let y)):
            return x.index == y.index && x.difficulty == y.difficulty
                && x.prompt == y.prompt && x.signal == y.signal
                && x.shouldPress == y.shouldPress
                && x.minDelayMs == y.minDelayMs && x.maxDelayMs == y.maxDelayMs
                && x.channel == y.channel
        case (.sequence(let x), .sequence(let y)):
            return x.index == y.index && x.difficulty == y.difficulty
                && x.items == y.items && x.answer == y.answer
                && x.showMs == y.showMs && x.prompt == y.prompt && x.choices == y.choices
        case (.grid(let x), .grid(let y)):
            return x.index == y.index && x.difficulty == y.difficulty
                && x.prompt == y.prompt && x.rows == y.rows && x.cols == y.cols
                && x.cells == y.cells && x.answer == y.answer && x.target == y.target
        case (.recall(let x), .recall(let y)):
            return x.index == y.index && x.difficulty == y.difficulty
                && x.prompt == y.prompt && x.choices == y.choices
                && x.correctId == y.correctId
        case (.numberLine(let x), .numberLine(let y)):
            return x.index == y.index && x.difficulty == y.difficulty
                && x.prompt == y.prompt && x.min == y.min && x.max == y.max
                && x.target == y.target && x.tolerance == y.tolerance
        case (.typed(let x), .typed(let y)):
            return x.index == y.index && x.difficulty == y.difficulty
                && x.prompt == y.prompt && x.placeholder == y.placeholder
                && x.answerPattern == y.answerPattern
        case (.sort(let x), .sort(let y)):
            return x.index == y.index && x.difficulty == y.difficulty
                && x.item == y.item && x.categories == y.categories
                && x.answerIndex == y.answerIndex
        default:
            return false
        }
    }
}
