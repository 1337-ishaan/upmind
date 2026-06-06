import Foundation

// MARK: - Executive Function construct (premium)

/// Generators for the five Executive Function games. The construct measures
/// higher-order control: alternating attention (trail-making B), rule
/// inference (WCST), set shifting, planning, and response inhibition.
///
/// All five games are gated behind the `upmind_premium` entitlement at
/// the catalog layer; the engine itself does not enforce gating.
enum ExecutiveGenerators {

    /// Trail Making B: connect 1→A→2→B… alternating numbers and letters.
    /// Single-trial game; renderer drives the sequence.
    static let TrailMakingB: any TrialGenerator = TrailMakingBGenerator()

    /// Rule Finding (WCST): sort a card by a hidden rule (even/odd, >50, etc.).
    static let RuleFinding: any TrialGenerator = RuleFindingGenerator()

    /// Set Shifting: apply one of several rules to a letter (vowel, half, etc.).
    /// The rule rotates every few trials.
    static let SetShifting: any TrialGenerator = SetShiftingGenerator()

    /// Planning (Zoo Map): plan a route from S to E on a grid with obstacles.
    /// Single-trial game; the engine just needs a valid grid trial.
    static let Planning: any TrialGenerator = PlanningGenerator()

    /// Inhibition: tap the *opposite* direction of the arrow shown.
    static let Inhibition: any TrialGenerator = InhibitionGenerator()

    // MARK: - Concrete generators

    struct TrailMakingBGenerator: TrialGenerator {
        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let size = 5
            let pairs = 4 // 1,A,2,B,3,C,4,D = 8 items
            var cells: [[String]] = Array(
                repeating: Array(repeating: "", count: size),
                count: size
            )
            var used = Set<String>()
            var firstPos: GridCell?
            // Place numbers 1..pairs then letters A..(pairs-1+A) at unique cells.
            for n in 1...pairs {
                var r = 0, c = 0
                repeat {
                    r = rng.int(upperBound: size)
                    c = rng.int(upperBound: size)
                } while used.contains("\(r):\(c)")
                used.insert("\(r):\(c)")
                cells[r][c] = String(n)
                if n == 1 { firstPos = GridCell(row: r, col: c) }
            }
            for k in 0..<pairs {
                var r = 0, c = 0
                repeat {
                    r = rng.int(upperBound: size)
                    c = rng.int(upperBound: size)
                } while used.contains("\(r):\(c)")
                used.insert("\(r):\(c)")
                cells[r][c] = String(UnicodeScalar(65 + k)!)
            }
            return .grid(GridTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "Alternate 1 → A → 2 → B …. Tap the next item.",
                rows: size, cols: size,
                cells: cells,
                answer: firstPos ?? GridCell(row: 0, col: 0),
                target: "1"
            ))
        }
    }

    struct RuleFindingGenerator: TrialGenerator {
        private struct Rule {
            let yesLabel: String
            let noLabel:  String
            let predicate: @Sendable (Int) -> Bool
        }
        private let rules: [Rule] = [
            Rule(yesLabel: "Even",           noLabel: "Odd",                 predicate: { $0 % 2 == 0 }),
            Rule(yesLabel: "Greater than 50", noLabel: "≤ 50",               predicate: { $0 > 50 }),
            Rule(yesLabel: "Multiple of 3",  noLabel: "Not a multiple of 3", predicate: { $0 % 3 == 0 })
        ]

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            // Rule rotates every 5 trials to mimic WCST's hidden rule shifts.
            let rule = rules[(index / 5) % rules.count]
            let n = rng.int(in: 1...100)
            let yes = rule.predicate(n)
            return .sort(SortTrial(
                id: UUID(), index: index, difficulty: difficulty,
                item: "\(n)",
                categories: [rule.yesLabel, rule.noLabel],
                answerIndex: yes ? 0 : 1
            ))
        }
    }

    struct SetShiftingGenerator: TrialGenerator {
        private struct Rule {
            let question: String
            let predicate: @Sendable (Character) -> Bool
        }
        private let rules: [Rule] = [
            Rule(question: "Is it a vowel?",
                 predicate: { "AEIOU".contains($0) }),
            Rule(question: "Is it in the first half of the alphabet (A–M)?",
                 predicate: { $0 <= "M" }),
            Rule(question: "Is it one of the letters in CODE?",
                 predicate: { "CODE".contains($0) })
        ]

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let rule = rules[(index / 4) % rules.count]
            let letter = Character(UnicodeScalar(65 + rng.int(upperBound: 26))!)
            let yes = rule.predicate(letter)
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "\(letter)\n\n\(rule.question)",
                choices: [
                    Choice(id: "yes", label: "Yes", correct:  yes),
                    Choice(id: "no",  label: "No",  correct: !yes)
                ],
                mode: nil
            ))
        }
    }

    struct PlanningGenerator: TrialGenerator {
        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let size = 4
            var cells: [[String]] = Array(
                repeating: Array(repeating: "", count: size),
                count: size
            )
            cells[0][0] = "S"
            cells[size - 1][size - 1] = "E"
            var used: Set<String> = ["0:0", "\(size - 1):\(size - 1)"]
            // Place 2–3 obstacles, avoiding S and E.
            let numObs = 2 + rng.int(upperBound: 2)
            var placed = 0
            while placed < numObs {
                let r = rng.int(upperBound: size)
                let c = rng.int(upperBound: size)
                let key = "\(r):\(c)"
                if !used.contains(key) {
                    used.insert(key)
                    cells[r][c] = "▓"
                    placed += 1
                }
            }
            return .grid(GridTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "Plan a route from S to E.",
                rows: size, cols: size,
                cells: cells,
                answer: GridCell(row: size - 1, col: size - 1),
                target: "E"
            ))
        }
    }

    struct InhibitionGenerator: TrialGenerator {
        private let directions: [String] = ["Up", "Down", "Left", "Right"]
        private let opposite: [String: String] = [
            "Up": "Down",
            "Down": "Up",
            "Left": "Right",
            "Right": "Left"
        ]

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let shown = directions[rng.int(upperBound: directions.count)]
            // Forced-unwrap: the dictionary literal above covers all four
            // direction strings, so `opposite[shown]` is always non-nil.
            let answer = opposite[shown]!
            let choices: [Choice] = directions.map { dir in
                Choice(id: dir.lowercased(), label: dir, correct: dir == answer)
            }
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "Arrow: \(shown). Tap the OPPOSITE.",
                choices: choices, mode: nil
            ))
        }
    }
}
