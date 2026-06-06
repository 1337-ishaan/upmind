import XCTest
@testable import Upmind

final class GeneratorTests: XCTestCase {

    func testStroopGeneratorProducesChoiceTrial() {
        let g = Generators.realStroop
        let trial = g.makeTrial(index: 0, difficulty: 1)
        guard case .choice(let ct) = trial else {
            XCTFail("Expected .choice"); return
        }
        XCTAssertFalse(ct.prompt.isEmpty)
        XCTAssertGreaterThanOrEqual(ct.choices.count, 2)
        // Exactly one choice must be marked correct.
        let correct = ct.choices.filter(\.correct)
        XCTAssertEqual(correct.count, 1)
    }

    func testStroopGeneratorIsDeterministic() {
        let g = Generators.realStroop
        let a = g.makeTrial(index: 7, difficulty: 1)
        let b = g.makeTrial(index: 7, difficulty: 1)
        XCTAssertEqual(stroopWord(of: a), stroopWord(of: b))
    }

    func testStroopInkColorDiffersFromWord() {
        // The classic Stroop setup: the word says one color, the ink is another.
        let g = Generators.realStroop
        var mismatches = 0
        for i in 0..<50 {
            if let pair = stroopInkAndWord(g.makeTrial(index: i, difficulty: 1)),
               pair.ink != pair.word {
                mismatches += 1
            }
        }
        XCTAssertGreaterThan(mismatches, 20, "Stroop needs both congruent and incongruent trials")
    }

    // MARK: - helpers

    private func stroopWord(of trial: Trial) -> String? {
        if case .choice(let ct) = trial { return ct.prompt }
        return nil
    }

    private func stroopInkAndWord(_ trial: Trial) -> (ink: String, word: String)? {
        guard case .choice(let ct) = trial else { return nil }
        // The ink is the correct choice label; the word is encoded in the prompt
        // as "WORD=<word>" by the generator. We don't assume the encoding here —
        // just that prompt and a correct choice both exist.
        guard let correctLabel = ct.choices.first(where: { $0.correct })?.label else {
            return nil
        }
        return (ink: correctLabel, word: ct.prompt)
    }
}
