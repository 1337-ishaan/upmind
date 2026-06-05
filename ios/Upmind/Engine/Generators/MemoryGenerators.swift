import Foundation

// MARK: - Memory construct

/// Generators for the seven Memory games. The construct measures both
/// short-term/working memory (digit/spatial spans, n-back) and
/// recognition/associative memory (paired, picture, word list).
enum MemoryGenerators {

    /// Digit Span: hear/see a sequence of digits, repeat forward or in reverse.
    static let DigitSpan: any TrialGenerator = DigitSpanGenerator()

    /// Corsi Blocks: blocks on a 3×3 grid light up in sequence; tap in order.
    static let CorsiBlocks: any TrialGenerator = CorsiBlocksGenerator()

    /// Spatial Span: cells on a larger grid (4×4 or 5×5) light up; tap in order.
    static let SpatialSpan: any TrialGenerator = SpatialSpanGenerator()

    /// Paired Associate: learn word pairs, then recall the partner of a cue.
    /// Produces `.recall` trials so the engine can score via the recall path.
    static let PairedAssociate: any TrialGenerator = PairedAssociateGenerator()

    /// Word List: show 8 words for a few seconds, then type as many as you can
    /// remember. Single typed trial; scored loosely (any non-empty input).
    static let WordList: any TrialGenerator = WordListGenerator()

    /// Picture Recognition: ask "was this shown before?" 50/50 yes/no split.
    static let PictureRecognition: any TrialGenerator = PictureRecognitionGenerator()

    /// N-Back: did the current letter match the one N steps ago?
    static let NBack: any TrialGenerator = NBackGenerator()

    // MARK: - Concrete generators

    struct DigitSpanGenerator: TrialGenerator {
        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let length = min(3 + difficulty + index / 4, 9)
            let digits: [String] = (0..<length).map { _ in String(rng.int(upperBound: 10)) }
            // Forward half, reverse half, deterministic per index.
            let isReverse = index % 2 == 1
            let answer = isReverse ? Array(digits.reversed()) : digits
            return .sequence(SequenceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                items: digits.map { .digit($0) },
                answer: answer,
                showMs: 1100,
                prompt: isReverse ? "Repeat in reverse order" : "Repeat the sequence",
                choices: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
            ))
        }
    }

    struct CorsiBlocksGenerator: TrialGenerator {
        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let side = 3
            let length = min(3 + difficulty + index / 4, 8)
            var seen = Set<String>()
            var items: [SequenceItem] = []
            while items.count < length {
                let r = rng.int(upperBound: side)
                let c = rng.int(upperBound: side)
                let key = "\(r):\(c)"
                if !seen.contains(key) {
                    seen.insert(key)
                    items.append(.block(row: r, col: c, gridSize: side))
                }
            }
            let answer = items.map(\.key)
            return .sequence(SequenceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                items: items,
                answer: answer,
                showMs: 950,
                prompt: "Tap the blocks in the order they lit up",
                choices: nil
            ))
        }
    }

    struct SpatialSpanGenerator: TrialGenerator {
        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let sides = [4, 5]
            let side = sides[rng.int(upperBound: sides.count)]
            let length = min(3 + difficulty + index / 4, 7)
            var seen = Set<String>()
            var items: [SequenceItem] = []
            while items.count < length {
                let r = rng.int(upperBound: side)
                let c = rng.int(upperBound: side)
                let key = "\(r):\(c)"
                if !seen.contains(key) {
                    seen.insert(key)
                    items.append(.block(row: r, col: c, gridSize: side))
                }
            }
            let answer = items.map(\.key)
            return .sequence(SequenceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                items: items,
                answer: answer,
                showMs: 950,
                prompt: "Tap positions in the order shown",
                choices: nil
            ))
        }
    }

    struct PairedAssociateGenerator: TrialGenerator {
        private let pairs: [(String, String)] = [
            ("Key", "Door"),
            ("Sun", "Moon"),
            ("Tree", "Leaf"),
            ("Cup", "Plate"),
            ("Fish", "Water"),
            ("Star", "Sky"),
            ("Book", "Page"),
            ("Hand", "Glove")
        ]

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let i = rng.int(upperBound: pairs.count)
            let pair = pairs[i]
            // Pick a distractor from another pair that isn't the correct answer.
            let distractorPairIdx = (i + 1 + rng.int(upperBound: pairs.count - 1)) % pairs.count
            let distractor = pairs[distractorPairIdx].1
            let correctId = pair.1.lowercased()
            let distractorId = distractor.lowercased()
            let choices = rng.shuffled([
                Choice(id: correctId,    label: pair.1,    correct: true),
                Choice(id: distractorId, label: distractor, correct: false)
            ])
            return .recall(RecallTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "What pairs with \(pair.0)?",
                choices: choices,
                correctId: correctId
            ))
        }
    }

    struct WordListGenerator: TrialGenerator {
        func makeTrial(index: Int, difficulty: Int) -> Trial {
            // Single-trial game: a fixed word list with a loose answer pattern
            // so any non-empty attempt scores. The actual "how many did you
            // remember" measure belongs at the renderer / scoring layer.
            let words = ["Apple", "Table", "River", "Moon", "Garden",
                         "Bridge", "Cloud", "Ladder"]
            return .typed(TypedTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "Remember and type these words: \(words.joined(separator: ", "))",
                placeholder: "apple, table, …",
                answerPattern: ".+"
            ))
        }
    }

    struct PictureRecognitionGenerator: TrialGenerator {
        private let items: [String] = [
            "🏠 House", "🌳 Tree", "🚗 Car", "✈️ Plane",
            "🐕 Dog",   "🐱 Cat",  "🎸 Guitar", "📚 Books"
        ]

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let item = items[rng.int(upperBound: items.count)]
            let wasShown = rng.unit() < 0.5
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "\(item)\n\nWas this shown earlier?",
                choices: [
                    Choice(id: "yes", label: "Yes", correct:  wasShown),
                    Choice(id: "no",  label: "No",  correct: !wasShown)
                ],
                mode: nil
            ))
        }
    }

    struct NBackGenerator: TrialGenerator {
        private let letters: [Character] = Array("BCDFGHJKLMNPQRSTVWZ")

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let n = 2  // catalog description: 2-back match detection
            let isMatch = rng.unit() < 0.5
            // Build a stream of length 12 + n; pick a current letter and an
            // "n-back" letter that either matches or doesn't.
            let current = letters[rng.int(upperBound: letters.count)]
            let nBackLetter: Character
            if isMatch {
                nBackLetter = current
            } else {
                var c = letters[rng.int(upperBound: letters.count)]
                while c == current { c = letters[rng.int(upperBound: letters.count)] }
                nBackLetter = c
            }
            let prompt = "Letter \(n) ago: \(nBackLetter)\nCurrent: \(current)\nDoes it match?"
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: prompt,
                choices: [
                    Choice(id: "yes", label: "Yes", correct:  isMatch),
                    Choice(id: "no",  label: "No",  correct: !isMatch)
                ],
                mode: nil
            ))
        }
    }
}
