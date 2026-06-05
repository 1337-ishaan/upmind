import Foundation

// MARK: - Numeracy construct

/// Generators for the seven Numeracy games. The construct measures number
/// sense (number line, quantity, estimation) and arithmetic fluency
/// (mental math, arithmetic verification, fraction comparison).
enum NumeracyGenerators {

    /// Mental Math: solve an arithmetic problem and pick the answer from
    /// 3 close distractors.
    static let MentalMath: any TrialGenerator = MentalMathGenerator()

    /// Number Line: place a target number on a 0–100 number line.
    static let NumberLine: any TrialGenerator = NumberLineGenerator()

    /// Estimation: approximate the product of two numbers from 4 choices.
    static let Estimation: any TrialGenerator = EstimationGenerator()

    /// Quantity: which array has more dots (or are they equal)?
    static let Quantity: any TrialGenerator = QuantityGenerator()

    /// Number Estimate: estimate how many dots are in the display by
    /// placing a marker on a number line.
    static let NumberEstimate: any TrialGenerator = NumberEstimateGenerator()

    /// Arithmetic Verify: is this equation true or false?
    static let ArithmeticVerify: any TrialGenerator = ArithmeticVerifyGenerator()

    /// Fraction Compare: which fraction is larger?
    static let FractionCompare: any TrialGenerator = FractionCompareGenerator()

    // MARK: - Concrete generators

    struct MentalMathGenerator: TrialGenerator {
        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let opIdx = rng.int(upperBound: 3)
            let op: String
            let a: Int
            let b: Int
            let answer: Int
            switch opIdx {
            case 0:
                op = "+"
                a = rng.int(in: 10...59)
                b = rng.int(in: 10...59)
                answer = a + b
            case 1:
                op = "−"
                a = rng.int(in: 30...79)
                b = rng.int(in: 5...max(5, a - 5))
                answer = a - b
            default:
                op = "×"
                a = rng.int(in: 2...12)
                b = rng.int(in: 2...11)
                answer = a * b
            }
            // Build 3 distractors that are near the answer but never equal it.
            var candidates: Set<Int> = [answer]
            let span = max(2, Int(Double(answer) * 0.20))
            while candidates.count < 4 {
                let delta = rng.int(in: -span...span)
                let c = answer + delta
                if c >= 0 && c != answer { candidates.insert(c) }
            }
            let labels = rng.shuffled(Array(candidates))
            let choices: [Choice] = labels.map { n in
                Choice(id: String(n), label: String(n), correct: n == answer)
            }
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "\(a) \(op) \(b) = ?",
                choices: choices,
                mode: nil
            ))
        }
    }

    struct NumberLineGenerator: TrialGenerator {
        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let target = Double(rng.int(in: 1...99))
            return .numberLine(NumberLineTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "Place \(Int(target)) on the line.",
                min: 0, max: 100, target: target,
                tolerance: 0.05
            ))
        }
    }

    struct EstimationGenerator: TrialGenerator {
        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let a = rng.int(in: 12...49)
            let b = rng.int(in: 12...49)
            let answer = a * b
            // 3 distractors that aren't equal to the answer.
            var candidates: Set<Int> = [answer]
            while candidates.count < 4 {
                let delta = rng.int(in: -100...100)
                let c = answer + delta
                if c > 0 && c != answer { candidates.insert(c) }
            }
            let labels = rng.shuffled(Array(candidates))
            let choices: [Choice] = labels.map { n in
                Choice(id: String(n), label: String(n), correct: n == answer)
            }
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "Estimate \(a) × \(b)",
                choices: choices,
                mode: nil
            ))
        }
    }

    struct QuantityGenerator: TrialGenerator {
        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            // To guarantee exactly one correct choice from {Left, Equal, Right},
            // we never produce equal arrays. The three buttons map cleanly to
            // a > b, a < b, or a == b.
            let a = rng.int(in: 5...44)
            var b = rng.int(in: 5...44)
            while b == a { b = rng.int(in: 5...44) }
            let aLarger = a > b
            let left = String(repeating: "●", count: a)
            let right = String(repeating: "●", count: b)
            let prompt = "\(left)\n\(right)\n\nWhich side has more?"
            let choices: [Choice] = [
                Choice(id: "left",  label: "◀ Left",  correct:  aLarger),
                Choice(id: "equal", label: "=",       correct: false),
                Choice(id: "right", label: "Right ▶", correct: !aLarger)
            ]
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: prompt, choices: choices, mode: nil
            ))
        }
    }

    struct NumberEstimateGenerator: TrialGenerator {
        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let count = rng.int(in: 3...20)
            let dots = String(repeating: "⬤", count: count)
            return .numberLine(NumberLineTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "\(dots)\nHow many dots?",
                min: 0, max: 25, target: Double(count),
                tolerance: 0.10
            ))
        }
    }

    struct ArithmeticVerifyGenerator: TrialGenerator {
        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let a = rng.int(in: 1...20)
            let b = rng.int(in: 1...20)
            let real = a + b
            let isTrue = rng.unit() < 0.5
            let shown = isTrue ? real : real + rng.int(in: 1...4)
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "\(a) + \(b) = \(shown)",
                choices: [
                    Choice(id: "true",  label: "True",  correct:  isTrue),
                    Choice(id: "false", label: "False", correct: !isTrue)
                ],
                mode: nil
            ))
        }
    }

    struct FractionCompareGenerator: TrialGenerator {
        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let aNum = rng.int(in: 2...9)
            let aDen = rng.int(in: 2...10)
            var bNum = rng.int(in: 2...9)
            var bDen = rng.int(in: 2...10)
            // Ensure the two fractions aren't equal in value.
            var attempts = 0
            while aNum * bDen == bNum * aDen && attempts < 20 {
                bNum = rng.int(in: 2...9)
                bDen = rng.int(in: 2...10)
                attempts += 1
            }
            if aNum * bDen == bNum * aDen {
                // Fallback: nudge to guarantee inequality.
                bDen += 1
            }
            let firstBigger = Double(aNum) / Double(aDen) > Double(bNum) / Double(bDen)
            let prompt = "\(aNum)/\(aDen)  vs  \(bNum)/\(bDen)\n\nWhich is larger?"
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: prompt,
                choices: [
                    Choice(id: "first",  label: "\(aNum)/\(aDen)", correct:  firstBigger),
                    Choice(id: "second", label: "\(bNum)/\(bDen)", correct: !firstBigger)
                ],
                mode: nil
            ))
        }
    }
}
