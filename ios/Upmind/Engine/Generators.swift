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
    /// Plan 2 will replace placeholders with real implementations.
    static func lookup(_ id: GameId) -> TrialGenerator? {
        guard let game = Games.game(id) else { return nil }
        return Placeholder(gameId: game.id, construct: game.construct, template: game.template)
    }
}
