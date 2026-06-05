import Foundation

/// The registry of all 42 game generators.
/// Plan 1 ships placeholders for every game so the engine can be tested
/// end-to-end; Plan 2 fills in the real implementations one by one.
enum Generators {

    /// Placeholder generator used in Plan 1. Produces a trivial choice trial
    /// so the engine can be exercised. Plan 2 replaces these with real ones.
    struct Placeholder: TrialGenerator {
        let gameId: GameId
        let construct: Construct
        let template: TemplateKind

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            let prompt = "\(gameId.rawValue) trial \(index + 1) (difficulty \(difficulty))"
            switch template {
            case .choice, .recall:
                return .choice(ChoiceTrial(
                    id: UUID(), index: index, difficulty: difficulty,
                    prompt: prompt,
                    choices: [
                        Choice(id: "a", label: "A", correct: true),
                        Choice(id: "b", label: "B", correct: false)
                    ],
                    mode: nil
                ))
            case .reaction:
                return .reaction(ReactionTrial(
                    id: UUID(), index: index, difficulty: difficulty,
                    prompt: prompt, signal: "●",
                    shouldPress: index % 2 == 0,
                    minDelayMs: 800, maxDelayMs: 2400,
                    channel: .visual
                ))
            case .sequence:
                return .sequence(SequenceTrial(
                    id: UUID(), index: index, difficulty: difficulty,
                    items: [.digit("3"), .digit("7"), .digit("1")],
                    answer: ["3", "7", "1"],
                    showMs: 700, prompt: "Repeat in order", choices: nil
                ))
            case .grid:
                return .grid(GridTrial(
                    id: UUID(), index: index, difficulty: difficulty,
                    prompt: prompt,
                    rows: 3, cols: 3,
                    cells: [["A","B","C"], ["D","E","F"], ["G","H","I"]],
                    answer: GridCell(row: 0, col: 0),
                    target: nil
                ))
            case .numberLine:
                return .numberLine(NumberLineTrial(
                    id: UUID(), index: index, difficulty: difficulty,
                    prompt: prompt,
                    min: 0, max: 100, target: 42,
                    tolerance: 0.05
                ))
            case .typed:
                return .typed(TypedTrial(
                    id: UUID(), index: index, difficulty: difficulty,
                    prompt: prompt, placeholder: "type here",
                    answerPattern: ".*"
                ))
            case .sort:
                return .sort(SortTrial(
                    id: UUID(), index: index, difficulty: difficulty,
                    item: "apple", categories: ["fruit", "vegetable"], answerIndex: 0
                ))
            }
        }
    }

    /// Look up the generator for a given game id.
    /// Stroop uses the real generator; everything else is a placeholder until Plan 2.
    static func lookup(_ id: GameId) -> TrialGenerator? {
        guard let game = Games.game(id) else { return nil }
        switch id {
        case .stroop:
            return realStroop
        default:
            return Placeholder(gameId: game.id, construct: game.construct, template: game.template)
        }
    }
}

extension Generators {

    /// Real Stroop generator. Prompts the user to name the ink color of a
    /// color word (e.g. the word "BLUE" rendered in red ink).
    /// The prompt encodes the word; the correct choice encodes the ink.
    /// This makes it observable to tests and easy to render in Plan 2.
    static let realStroop = StroopGenerator()

    struct StroopGenerator: TrialGenerator {
        private let colors: [String] = ["RED", "GREEN", "BLUE", "YELLOW"]
        private let inks:   [String] = ["red", "green", "blue", "yellow"]

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            // 50% chance of incongruent (ink != word) to keep it challenging.
            let wordIdx = rng.int(upperBound: colors.count)
            let word = colors[wordIdx]
            let inkIdx: Int
            if rng.unit() < 0.5 {
                inkIdx = wordIdx
            } else {
                inkIdx = (wordIdx + 1 + rng.int(upperBound: inks.count - 1)) % inks.count
            }
            let ink = inks[inkIdx]
            // Distractors: the other three inks (regardless of word).
            let distractors = inks.indices.filter { $0 != inkIdx }.map { inks[$0] }
            let choiceLabels = rng.shuffled([ink] + distractors)
            let choices: [Choice] = choiceLabels.map { label in
                Choice(id: label.lowercased(), label: label, correct: label == ink)
            }
            return .choice(ChoiceTrial(
                id: UUID(),
                index: index,
                difficulty: difficulty,
                prompt: word,
                choices: choices,
                mode: nil
            ))
        }
    }
}
