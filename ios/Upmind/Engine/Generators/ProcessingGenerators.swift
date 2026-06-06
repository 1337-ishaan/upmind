import Foundation

// MARK: - Processing Speed construct

/// Generators for the five Processing Speed games. The construct measures
/// how quickly the user can apply simple rules to many items: symbol-digit
/// substitution, cancellation, trail-making, and visual comparison.
enum ProcessingGenerators {

    /// Symbol-Digit: map a symbol to a digit using a small legend.
    static let SymbolDigit: any TrialGenerator = SymbolDigitGenerator()

    /// Cancellation: tap every occurrence of the target letter in a grid.
    /// Single-trial game; the engine just needs a valid grid trial.
    static let Cancellation: any TrialGenerator = CancellationGenerator()

    /// Trail Making A: connect numbered dots 1→2→3 in order on a grid.
    static let TrailMakingA: any TrialGenerator = TrailMakingAGenerator()

    /// Pattern Comparison: are these two block patterns the same or different?
    static let PatternComparison: any TrialGenerator = PatternComparisonGenerator()

    /// Letter Comparison: are these two letter strings the same or different?
    static let LetterComparison: any TrialGenerator = LetterComparisonGenerator()

    // MARK: - Concrete generators

    struct SymbolDigitGenerator: TrialGenerator {
        // Five-pair legend; the user always sees the same legend across trials.
        private let symbols: [String] = ["△", "○", "□", "☆", "◇"]
        private let digits:  [Int]    = [1, 2, 3, 4, 5]

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let qIdx = rng.int(upperBound: symbols.count)
            let symbol = symbols[qIdx]
            let answer = digits[qIdx]
            // Distractors: the other 3 digits, plus the answer = 4 choices.
            let distractors = digits.indices.filter { $0 != qIdx }.map { digits[$0] }
            let labels = rng.shuffled([answer] + distractors)
            let legend = zip(symbols, digits).map { "\($0)=\($1)" }.joined(separator: "  ")
            let prompt = "\(symbol)\n\nLegend: \(legend)"
            let choices: [Choice] = labels.map { n in
                Choice(id: String(n), label: String(n), correct: n == answer)
            }
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: prompt, choices: choices, mode: nil
            ))
        }
    }

    struct CancellationGenerator: TrialGenerator {
        private let symbols: [String] = ["★", "◉", "▲", "●"]

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let targetIdx = rng.int(upperBound: symbols.count)
            let target = symbols[targetIdx]
            let distractor = symbols[(targetIdx + 1) % symbols.count]
            let size = 5
            var cells: [[String]] = Array(
                repeating: Array(repeating: distractor, count: size),
                count: size
            )
            // Place 4–7 targets at random unique positions. Record the
            // first one as the canonical "answer" for the engine's
            // single-cell grid response model.
            let numTargets = 4 + rng.int(upperBound: 4)
            var used = Set<String>()
            var firstAnswer: GridCell?
            while used.count < numTargets {
                let r = rng.int(upperBound: size)
                let c = rng.int(upperBound: size)
                let key = "\(r):\(c)"
                if !used.contains(key) {
                    used.insert(key)
                    cells[r][c] = target
                    if firstAnswer == nil { firstAnswer = GridCell(row: r, col: c) }
                }
            }
            return .grid(GridTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "Tap every \(target) you see.",
                rows: size, cols: size,
                cells: cells,
                answer: firstAnswer ?? GridCell(row: 0, col: 0),
                target: target
            ))
        }
    }

    struct TrailMakingAGenerator: TrialGenerator {
        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let size = 5
            let count = 8
            var cells: [[String]] = Array(
                repeating: Array(repeating: "", count: size),
                count: size
            )
            var used = Set<String>()
            var firstPos: GridCell?
            var placed = 0
            while placed < count {
                let r = rng.int(upperBound: size)
                let c = rng.int(upperBound: size)
                let key = "\(r):\(c)"
                if !used.contains(key) {
                    used.insert(key)
                    placed += 1
                    cells[r][c] = String(placed)
                    if placed == 1 { firstPos = GridCell(row: r, col: c) }
                }
            }
            return .grid(GridTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "Tap 1, then the next, in order.",
                rows: size, cols: size,
                cells: cells,
                answer: firstPos ?? GridCell(row: 0, col: 0),
                target: "1"
            ))
        }
    }

    struct PatternComparisonGenerator: TrialGenerator {
        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            // Show two 4-cell patterns; choose same/different deterministically.
            let same = rng.unit() < 0.5
            let left = (0..<4).map { _ in rng.unit() < 0.5 ? "■" : "□" }
            var right = left
            if !same {
                // Flip exactly one cell so the two patterns differ.
                let flipIdx = rng.int(upperBound: right.count)
                right[flipIdx] = right[flipIdx] == "■" ? "□" : "■"
            }
            let prompt = "\(left.joined())  vs  \(right.joined())"
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: prompt,
                choices: [
                    Choice(id: "same",      label: "Same",      correct:  same),
                    Choice(id: "different", label: "Different", correct: !same)
                ],
                mode: nil
            ))
        }
    }

    struct LetterComparisonGenerator: TrialGenerator {
        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let length = 4 + rng.int(upperBound: 4) // 4–7
            let left: String = (0..<length).map { _ in
                String(UnicodeScalar(65 + rng.int(upperBound: 26))!)
            }.joined()
            let same = rng.unit() < 0.5
            var right = left
            if !same {
                var arr = Array(right)
                let flipIdx = rng.int(upperBound: arr.count)
                // Pick a different letter than the current one at flipIdx.
                var newScalar = 65 + rng.int(upperBound: 26)
                while UnicodeScalar(newScalar) == arr[flipIdx].unicodeScalars.first {
                    newScalar = 65 + rng.int(upperBound: 26)
                }
                arr[flipIdx] = Character(UnicodeScalar(newScalar)!)
                right = String(arr)
            }
            let prompt = "\(left)\n\(right)"
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: prompt,
                choices: [
                    Choice(id: "same",      label: "Same",      correct:  same),
                    Choice(id: "different", label: "Different", correct: !same)
                ],
                mode: nil
            ))
        }
    }
}
