import Foundation

// MARK: - Problem-Solving construct

/// Generators for the five Problem-Solving games. The construct measures
/// fluid reasoning (matrix, logic), spatial cognition (mental rotation,
/// pattern matching), and planning (towers).
enum ProblemGenerators {

    /// Matrix Reasoning: complete a simple sequence pattern.
    static let MatrixReasoning: any TrialGenerator = MatrixReasoningGenerator()

    /// Logic: pick the valid conclusion of a syllogism.
    static let Logic: any TrialGenerator = LogicGenerator()

    /// Mental Rotation: pick the shape that matches the cue after rotation.
    static let MentalRotation: any TrialGenerator = MentalRotationGenerator()

    /// Pattern Match: find the matching tile on a grid.
    static let PatternMatch: any TrialGenerator = PatternMatchGenerator()

    /// Tower of Hanoi: plan the first move (which peg).
    static let TowerOfHanoi: any TrialGenerator = TowerOfHanoiGenerator()

    // MARK: - Concrete generators

    struct MatrixReasoningGenerator: TrialGenerator {
        // A simple sequence: pick the next item in a rotating pattern.
        // We use a 4-symbol cycle so the answer is unambiguous and exactly
        // one of the 4 choices is correct.
        private let cycles: [[String]] = [
            ["△", "○", "□", "☆"],
            ["A",  "B", "C", "D"],
            ["1",  "2", "3", "4"],
            ["↑",  "→", "↓", "←"]
        ]

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let cycle = cycles[rng.int(upperBound: cycles.count)]
            let startIdx = rng.int(upperBound: cycle.count)
            // Show three consecutive items from the cycle; the answer is the next.
            let shown = (0..<3).map { cycle[(startIdx + $0) % cycle.count] }
            let answer = cycle[(startIdx + 3) % cycle.count]
            // Choices: cycle items in shuffled order. Each is unique → exactly one correct.
            let choiceLabels = rng.shuffled(cycle)
            let choices: [Choice] = choiceLabels.map { sym in
                Choice(id: sym, label: sym, correct: sym == answer)
            }
            let prompt = "\(shown.joined(separator: " ")) → ?"
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: prompt, choices: choices, mode: nil
            ))
        }
    }

    struct LogicGenerator: TrialGenerator {
        private let items: [(stem: String, correct: String, d1: String, d2: String)] = [
            ("All mammals are warm-blooded. Whales are mammals. So whales ___?",
             "are warm-blooded", "are cold-blooded", "cannot be determined"),
            ("If A > B and B > C, then A ___ C.",
             ">", "<", "="),
            ("No cats are dogs. All dogs are mammals. So some cats ___ mammals.",
             "may or may not be", "are not", "always are"),
            ("Some birds can fly. Penguins are birds. So penguins ___ fly.",
             "may or may not", "definitely cannot", "definitely can"),
            ("If it rains, the ground gets wet. The ground is dry. So it ___.",
             "did not rain", "did rain", "always rains")
        ]

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let i = rng.int(upperBound: items.count)
            let item = items[i]
            let shuffled = rng.shuffled([
                Choice(id: "correct", label: item.correct, correct: true),
                Choice(id: "d1",      label: item.d1,      correct: false),
                Choice(id: "d2",      label: item.d2,      correct: false)
            ])
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: item.stem, choices: shuffled, mode: nil
            ))
        }
    }

    struct MentalRotationGenerator: TrialGenerator {
        // We model rotation as "which of these matches the cue?" The four
        // candidates are distinct rotations of a base shape. Exactly one
        // is the cue itself.
        private let pool: [(cue: String, match: String, d1: String, d2: String)] = [
            ("◐", "◐", "◑", "◒"),
            ("◓", "◓", "◑", "◐"),
            ("▲", "▲", "▼", "◀"),
            ("◆", "◆", "■", "●")
        ]

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let i = rng.int(upperBound: pool.count)
            let item = pool[i]
            let shuffled = rng.shuffled([
                Choice(id: "match", label: item.match, correct: true),
                Choice(id: "d1",    label: item.d1,    correct: false),
                Choice(id: "d2",    label: item.d2,    correct: false)
            ])
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "Cue: \(item.cue)\nWhich is the same after rotation?",
                choices: shuffled, mode: nil
            ))
        }
    }

    struct PatternMatchGenerator: TrialGenerator {
        private let patterns: [String] = ["◐", "◑", "◒", "◓", "◆", "●", "▲", "■"]

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let size = 4
            let target = patterns[rng.int(upperBound: patterns.count)]
            let filler = patterns.filter { $0 != target }
            var cells: [[String]] = Array(
                repeating: Array(repeating: "", count: size),
                count: size
            )
            // Fill grid with filler symbols.
            for r in 0..<size {
                for c in 0..<size {
                    cells[r][c] = filler[rng.int(upperBound: filler.count)]
                }
            }
            // Place exactly one target cell.
            let row = rng.int(upperBound: size)
            let col = rng.int(upperBound: size)
            cells[row][col] = target
            return .grid(GridTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "Tap the matching \(target)",
                rows: size, cols: size,
                cells: cells,
                answer: GridCell(row: row, col: col),
                target: target
            ))
        }
    }

    struct TowerOfHanoiGenerator: TrialGenerator {
        private let pegs: [String] = ["A", "B", "C"]

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            // Pick which peg the next disc should move TO. The "from" peg is
            // baked into the prompt; the answer is the destination peg.
            let fromIdx = rng.int(upperBound: pegs.count)
            var toIdx = rng.int(upperBound: pegs.count)
            while toIdx == fromIdx { toIdx = rng.int(upperBound: pegs.count) }
            return .sort(SortTrial(
                id: UUID(), index: index, difficulty: difficulty,
                item: "Move the top disc from peg \(pegs[fromIdx]) — where to?",
                categories: pegs.map { "Peg \($0)" },
                answerIndex: toIdx
            ))
        }
    }
}
