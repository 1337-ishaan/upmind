import SnapshotTesting
import SwiftUI
import XCTest
@testable import Upmind

/// Snapshot tests for all trial renderers.
///
/// The eight `Trial` shapes are: choice, reaction, sequence, grid,
/// recall, numberLine, typed, sort. `Recall` reuses `ChoiceRenderer`
/// (it has the same shape), so the seven renderer files map to seven
/// distinct test methods here plus an extra coverage case for
/// `ChoiceRenderer` showing the after-answer feedback state.
///
/// These tests use `withSnapshotTesting(record: .never)` so they fail
/// deterministically with a "no reference recorded" message until
/// reference PNGs are committed. To record references locally:
///
///   SNAPSHOT_TESTING_RECORD=all xcodebuild test -scheme Upmind
///
/// After the PNGs are generated under
/// `Tests/SnapshotTests/__Snapshots__/RenderersSnapshotTests/`, commit
/// them and re-run the tests; they will then assert against the
/// recorded references and fail loudly if a renderer's output drifts.
@MainActor
final class RenderersSnapshotTests: XCTestCase {

    private func render<V: View>(_ view: V, size: CGSize = .init(width: 390, height: 844)) -> UIImage {
        let renderer = ImageRenderer(content:
            view
                .frame(width: size.width, height: size.height)
                .background(ColorTokens.dark.surfaceBase)
                .environment(\.theme, ColorTokens.dark)
        )
        renderer.scale = 2.0
        return renderer.uiImage ?? UIImage()
    }

    // MARK: - Choice

    func testChoiceRendererDefault() {
        let trial = ChoiceTrial(
            id: UUID(), index: 0, difficulty: 1,
            prompt: "Name the ink color",
            choices: [
                Choice(id: "red", label: "Red", correct: true),
                Choice(id: "green", label: "Green", correct: false),
                Choice(id: "blue", label: "Blue", correct: false),
                Choice(id: "yellow", label: "Yellow", correct: false),
            ],
            mode: nil
        )
        let view = ChoiceRenderer(trial: trial, lastCorrect: nil, onAnswer: { _ in })
        withSnapshotTesting(record: .never) {
            assertSnapshot(of: render(view), as: .image)
        }
    }

    func testChoiceRendererWithCorrectFeedback() {
        let trial = ChoiceTrial(
            id: UUID(), index: 0, difficulty: 1,
            prompt: "Tap the red one",
            choices: [
                Choice(id: "a", label: "Red", correct: true),
                Choice(id: "b", label: "Blue", correct: false),
            ],
            mode: nil
        )
        let view = ChoiceRenderer(trial: trial, lastCorrect: true, onAnswer: { _ in })
        withSnapshotTesting(record: .never) {
            assertSnapshot(of: render(view), as: .image)
        }
    }

    // MARK: - Reaction

    func testReactionRendererWaitPhase() {
        let trial = ReactionTrial(
            id: UUID(), index: 0, difficulty: 1,
            prompt: "Tap when you see the signal",
            signal: "●",
            shouldPress: true,
            minDelayMs: 1500, maxDelayMs: 3000,
            channel: .visual
        )
        let view = ReactionRenderer(trial: trial, lastCorrect: nil, onAnswer: { _ in })
        withSnapshotTesting(record: .never) {
            assertSnapshot(of: render(view), as: .image)
        }
    }

    // MARK: - Sequence

    func testSequenceRenderer() {
        let trial = SequenceTrial(
            id: UUID(), index: 0, difficulty: 1,
            items: [.digit("3"), .digit("7"), .digit("1"), .digit("9")],
            answer: ["3", "7", "1", "9"],
            showMs: 700, prompt: "Repeat in order", choices: nil
        )
        let view = SequenceRenderer(trial: trial, lastCorrect: nil, onAnswer: { _ in })
        withSnapshotTesting(record: .never) {
            assertSnapshot(of: render(view), as: .image)
        }
    }

    // MARK: - Grid

    func testGridRenderer() {
        let trial = GridTrial(
            id: UUID(), index: 0, difficulty: 1,
            prompt: "Find the letter T",
            rows: 3, cols: 3,
            cells: [["A","B","T"], ["D","E","F"], ["G","H","I"]],
            answer: GridCell(row: 0, col: 2),
            target: "T"
        )
        let view = GridRenderer(trial: trial, lastCorrect: nil, onAnswer: { _ in })
        withSnapshotTesting(record: .never) {
            assertSnapshot(of: render(view), as: .image)
        }
    }

    // MARK: - NumberLine

    func testNumberLineRenderer() {
        let trial = NumberLineTrial(
            id: UUID(), index: 0, difficulty: 1,
            prompt: "Place the number 42 on the line",
            min: 0, max: 100, target: 42, tolerance: 0.05
        )
        let view = NumberLineRenderer(trial: trial, lastCorrect: nil, onAnswer: { _ in })
        withSnapshotTesting(record: .never) {
            assertSnapshot(of: render(view), as: .image)
        }
    }

    // MARK: - Typed

    func testTypedRenderer() {
        let trial = TypedTrial(
            id: UUID(), index: 0, difficulty: 1,
            prompt: "Type as many animals as you can",
            placeholder: "cat, dog, ...",
            answerPattern: ".*"
        )
        let view = TypedRenderer(trial: trial, lastCorrect: nil, onAnswer: { _ in })
        withSnapshotTesting(record: .never) {
            assertSnapshot(of: render(view), as: .image)
        }
    }

    // MARK: - Sort

    func testSortRenderer() {
        let trial = SortTrial(
            id: UUID(), index: 0, difficulty: 1,
            item: "apple",
            categories: ["Fruit", "Vegetable", "Mineral"],
            answerIndex: 0
        )
        let view = SortRenderer(trial: trial, lastCorrect: nil, onAnswer: { _ in })
        withSnapshotTesting(record: .never) {
            assertSnapshot(of: render(view), as: .image)
        }
    }
}
