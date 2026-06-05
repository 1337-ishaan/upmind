import XCTest
import SnapshotTesting
import SwiftUI
@testable import Upmind

/// Snapshot tests for `ChoiceRenderer`.
///
/// These are stubs in Plan 2 Round 1. The reference images are recorded
/// in Round 5 (Plan 2, R5) for all 8 renderers. The test uses
/// `withSnapshotTesting(record: .never)` so no PNG is written — that
/// way the test fails deterministically with "No reference; recording
/// disabled" on every run, and `XCTExpectFailure` consumes that
/// failure consistently.
///
/// To enable in Round 5: delete the `XCTExpectFailure` wrapper and the
/// `withSnapshotTesting(record: .never)` override, then set
/// `record: .all` (or pass `SNAPSHOT_TESTING_RECORD=all` to xcodebuild
/// test) to write the reference PNGs. Then re-run with the override
/// removed and no record flag to assert against the references.
final class ChoiceRendererSnapshotTests: XCTestCase {

    func testIdleRendersPromptAndChoices() {
        let trial = ChoiceTrial(
            id: UUID(),
            index: 0,
            difficulty: 1,
            prompt: "Name the ink color",
            choices: [
                Choice(id: "red",    label: "red",    correct: true),
                Choice(id: "green",  label: "green",  correct: false),
                Choice(id: "blue",   label: "blue",   correct: false),
                Choice(id: "yellow", label: "yellow", correct: false)
            ],
            mode: nil
        )
        let view = ChoiceRenderer(trial: trial, lastCorrect: nil, onAnswer: { _ in })
            .frame(width: 390, height: 844)
            .background(ColorTokens.light.surfaceBase)

        XCTExpectFailure(
            "Snapshot references for ChoiceRenderer are recorded in Plan 2 Round 5"
        ) {
            withSnapshotTesting(record: .never) {
                assertSnapshot(of: view, as: .image)
            }
        }
    }

    func testAfterAnswerShowsCorrectFeedback() {
        let trial = ChoiceTrial(
            id: UUID(),
            index: 2,
            difficulty: 1,
            prompt: "Name the ink color",
            choices: [
                Choice(id: "red",    label: "red",    correct: true),
                Choice(id: "green",  label: "green",  correct: false),
                Choice(id: "blue",   label: "blue",   correct: false),
                Choice(id: "yellow", label: "yellow", correct: false)
            ],
            mode: nil
        )
        let view = ChoiceRenderer(trial: trial, lastCorrect: true, onAnswer: { _ in })
            .frame(width: 390, height: 844)
            .background(ColorTokens.light.surfaceBase)

        XCTExpectFailure(
            "Snapshot references for ChoiceRenderer are recorded in Plan 2 Round 5"
        ) {
            withSnapshotTesting(record: .never) {
                assertSnapshot(of: view, as: .image)
            }
        }
    }
}
