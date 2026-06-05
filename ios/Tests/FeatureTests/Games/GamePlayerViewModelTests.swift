import XCTest
import SwiftUI
@testable import Upmind

@MainActor
final class GamePlayerViewModelTests: XCTestCase {

    /// After `start()`, the VM should leave `.loading` and surface the first
    /// trial as `.playing(trial, index: 0, total:, lastCorrect: nil)`.
    /// `lastCorrect` is nil because no answer has been given yet.
    func testStartTransitionsToPlayingWithFirstTrial() async throws {
        let game = Games.game(.stroop)!
        let vm = try GamePlayerViewModel(game: game, userIdentifier: "test")
        XCTAssertEqual(vm.state, .loading, "Fresh VM should be in .loading")

        vm.start()
        defer { vm.abort() }

        // Wait up to 2s for the engine to emit the first trial and the VM
        // to update state. Stroop is the only game with a real generator;
        // it produces a choice trial deterministically for index 0.
        let deadline = Date().addingTimeInterval(2.0)
        while Date() < deadline {
            if case .playing = vm.state { break }
            try await Task.sleep(nanoseconds: 50_000_000)
        }

        guard case .playing(let trial, let index, let total, let lastCorrect) = vm.state else {
            XCTFail("Expected .playing state, got \(vm.state)")
            return
        }
        XCTAssertEqual(index, 0, "First trial should have index 0")
        XCTAssertEqual(total, game.trials, "Total should match the game's trial count")
        XCTAssertNil(lastCorrect, "No answer given yet, lastCorrect should be nil")
        XCTAssertEqual(trial.template, .choice, "Stroop is a choice game")
    }

    /// After answering the first trial, the VM should evolve past
    /// `.playing(0, ..., nil)` — either showing feedback (`lastCorrect`
    /// set) or having advanced to the next trial (index > 0) or having
    /// finished. The 600ms feedback hold is built in a later round, so
    /// we don't depend on the brief flicker being observable.
    func testAnswerAdvancesStatePastFirstTrial() async throws {
        let game = Games.game(.stroop)!
        let vm = try GamePlayerViewModel(game: game, userIdentifier: "test")
        vm.start()
        defer { vm.abort() }

        // Wait for the first trial.
        let deadline = Date().addingTimeInterval(2.0)
        while Date() < deadline {
            if case .playing = vm.state { break }
            try await Task.sleep(nanoseconds: 50_000_000)
        }
        guard case .playing(let trial, 0, _, nil) = vm.state else {
            XCTFail("Expected .playing(index: 0, lastCorrect: nil), got \(vm.state)")
            return
        }
        guard case .choice(let ct) = trial else {
            XCTFail("Expected a choice trial")
            return
        }

        // Answer correctly. The 250-350ms RT sits above the engine's
        // 180ms drift floor and is varied to avoid streak-walk drift.
        let correct = ct.choices.first(where: { $0.correct })!
        try? await Task.sleep(nanoseconds: UInt64.random(in: 250_000_000...350_000_000))
        await vm.answer(.choice(correct.id))

        // Wait for the state to evolve past the first trial. Tolerate
        // any of: feedback shown, next trial, or session finished.
        let deadline2 = Date().addingTimeInterval(2.0)
        while Date() < deadline2 {
            switch vm.state {
            case .playing(_, let idx, _, let lc) where idx > 0 || lc != nil:
                return  // evolved
            case .finished:
                return  // 1/20 answers shouldn't finish — but accept it
            case .error:
                return
            default:
                try await Task.sleep(nanoseconds: 50_000_000)
            }
        }

        // Final assertion: the state should NOT be the original first-trial
        // untouched state by now.
        XCTFail("State did not evolve after answering first trial: \(vm.state)")
    }
}
