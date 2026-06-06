import Foundation

// MARK: - Attention construct

/// Generators for the seven Attention games. The construct measures the
/// ability to focus, switch focus, ignore distractors, and react quickly.
///
/// Each generator is deterministic: the same `(index, difficulty)` pair
/// produces the same trial across runs, via `SeededRNG` keyed on `index`.
enum AttentionGenerators {

    /// Stroop: name the ink color of a color word. Half congruent, half
    /// incongruent, so the user can't trivially read the word.
    static let Stroop: any TrialGenerator = StroopGenerator()

    /// Flanker Focus: pick the direction of the center arrow. Distractor
    /// arrows on either side may agree (congruent) or disagree (incongruent).
    static let Flanker: any TrialGenerator = FlankerGenerator()

    /// Go / No-Go: react to animals, withhold for objects. Tests response
    /// inhibition and sustained attention.
    static let GoNoGo: any TrialGenerator = GoNoGoGenerator()

    /// Context Switch: alternates between two rules every few trials. Tests
    /// task-set reconfiguration.
    static let ContextSwitch: any TrialGenerator = ContextSwitchGenerator()

    /// Visual Search: find the target letter hidden in a grid of distractors.
    static let VisualSearch: any TrialGenerator = VisualSearchGenerator()

    /// Divided Attention: react to either of two channels (visual / audio).
    static let DividedAttention: any TrialGenerator = DividedAttentionGenerator()

    /// Simple Reaction: tap as soon as the signal appears (with a withhold
    /// trial sprinkled in to catch anticipators).
    static let SimpleReaction: any TrialGenerator = SimpleReactionGenerator()

    // MARK: - Concrete generators

    struct StroopGenerator: TrialGenerator {
        private let words: [String] = ["RED", "GREEN", "BLUE", "YELLOW"]
        private let inks:  [String] = ["red", "green", "blue", "yellow"]

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let wordIdx = rng.int(upperBound: words.count)
            let word = words[wordIdx]
            let inkIdx: Int
            if rng.unit() < 0.5 {
                inkIdx = wordIdx
            } else {
                inkIdx = (wordIdx + 1 + rng.int(upperBound: inks.count - 1)) % inks.count
            }
            let ink = inks[inkIdx]
            let distractors = inks.indices.filter { $0 != inkIdx }.map { inks[$0] }
            let choiceLabels = rng.shuffled([ink] + distractors)
            let choices: [Choice] = choiceLabels.map { label in
                Choice(id: label.lowercased(), label: label, correct: label == ink)
            }
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: word, choices: choices, mode: nil
            ))
        }
    }

    struct FlankerGenerator: TrialGenerator {
        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let targetLeft = rng.unit() < 0.5
            let congruent = rng.unit() < 0.5
            let count = rng.unit() < 0.4 ? 3 : 5
            let targetPos = rng.int(upperBound: count)
            let target: Character = targetLeft ? "←" : "→"
            let flanker: Character = congruent ? target : (targetLeft ? "→" : "←")
            var display = ""
            for k in 0..<count {
                display.append(k == targetPos ? target : flanker)
            }
            let prompt = "Target arrow direction:\n\(display)"
            let choices: [Choice] = [
                Choice(id: "left",  label: "←", correct: targetLeft),
                Choice(id: "right", label: "→", correct: !targetLeft)
            ]
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: prompt, choices: choices, mode: nil
            ))
        }
    }

    struct GoNoGoGenerator: TrialGenerator {
        private let animals: [String] = ["Dog", "Cat", "Bird", "Fish", "Horse"]
        private let objects: [String] = ["Chair", "Table", "Car", "Book", "Cup"]

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            // 70% animals (press), 30% objects (withhold) — matches catalog "Press for animals only".
            let isAnimal = rng.unit() < 0.7
            let stimulus = isAnimal
                ? animals[rng.int(upperBound: animals.count)]
                : objects[rng.int(upperBound: objects.count)]
            return .reaction(ReactionTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "Press for animals. Hold for objects.",
                signal: stimulus,
                shouldPress: isAnimal,
                minDelayMs: 800, maxDelayMs: 2000,
                channel: .visual
            ))
        }
    }

    struct ContextSwitchGenerator: TrialGenerator {
        // The rule alternates every 5 trials so the player gets a chance to
        // settle then switch — a hallmark of context-switch paradigms.
        private struct Rule {
            let question: String
            let predicate: @Sendable (Int) -> Bool
        }
        private let rules: [Rule] = [
            Rule(question: "Is it even?",            predicate: { $0 % 2 == 0 }),
            Rule(question: "Is it greater than 50?", predicate: { $0 > 50 }),
            Rule(question: "Is it a multiple of 5?", predicate: { $0 % 5 == 0 }),
            Rule(question: "Is it a multiple of 3?", predicate: { $0 % 3 == 0 })
        ]

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let rule = rules[(index / 5) % rules.count]
            let number = rng.int(in: 1...100)
            let isYes = rule.predicate(number)
            let prompt = "\(rule.question)\n\n\(number)"
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: prompt,
                choices: [
                    Choice(id: "yes", label: "Yes", correct:  isYes),
                    Choice(id: "no",  label: "No",  correct: !isYes)
                ],
                mode: nil
            ))
        }
    }

    struct VisualSearchGenerator: TrialGenerator {
        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let size = 5
            // Pick a target letter from A–C and a distractor from D–F so they
            // never collide.
            let target = String(UnicodeScalar(65 + rng.int(upperBound: 3))!)
            let distractor = String(UnicodeScalar(68 + rng.int(upperBound: 3))!)
            let row = rng.int(upperBound: size)
            let col = rng.int(upperBound: size)
            var cells: [[String]] = Array(
                repeating: Array(repeating: distractor, count: size),
                count: size
            )
            cells[row][col] = target
            return .grid(GridTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "Find the \(target)",
                rows: size, cols: size,
                cells: cells,
                answer: GridCell(row: row, col: col),
                target: target
            ))
        }
    }

    struct DividedAttentionGenerator: TrialGenerator {
        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let mode = rng.unit()
            let prompt: String
            let signal: String
            let channel: ReactionChannel
            let shouldPress: Bool
            if mode < 0.15 {
                prompt = "Tap on visual only (audio ignored)."
                signal = "GO!"
                channel = .visual
                shouldPress = true
            } else if mode < 0.30 {
                prompt = "Tap on audio cue only."
                signal = "🔊 TONE"
                channel = .audio
                shouldPress = true
            } else {
                prompt = "Dual channel: tap on signal."
                signal = "GO!"
                channel = .either
                shouldPress = true
            }
            return .reaction(ReactionTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: prompt, signal: signal,
                shouldPress: shouldPress,
                minDelayMs: 1000, maxDelayMs: 2500,
                channel: channel
            ))
        }
    }

    struct SimpleReactionGenerator: TrialGenerator {
        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let mode = rng.unit()
            // 10% withhold, 20% color-match, 70% generic flash.
            if mode < 0.10 {
                return .reaction(ReactionTrial(
                    id: UUID(), index: index, difficulty: difficulty,
                    prompt: "Wait for the signal. (No signal will appear.)",
                    signal: "",
                    shouldPress: false,
                    minDelayMs: 1500, maxDelayMs: 3000,
                    channel: .visual
                ))
            }
            if mode < 0.30 {
                let colors = ["red", "green", "amber", "blue"]
                let color = colors[rng.int(upperBound: colors.count)]
                return .reaction(ReactionTrial(
                    id: UUID(), index: index, difficulty: difficulty,
                    prompt: "Tap when you see \(color.uppercased()).",
                    signal: color,
                    shouldPress: true,
                    minDelayMs: 1200, maxDelayMs: 3000,
                    channel: .visual
                ))
            }
            return .reaction(ReactionTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "Tap as soon as the screen flashes.",
                signal: "TAP!",
                shouldPress: true,
                minDelayMs: 1000, maxDelayMs: 3500,
                channel: .visual
            ))
        }
    }
}
