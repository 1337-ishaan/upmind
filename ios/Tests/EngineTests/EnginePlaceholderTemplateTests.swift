import XCTest
@testable import Upmind

/// Round-trip tests for the seven non-choice placeholder templates.
///
/// The Stroop round-trip test in `EngineRoundTripTests.swift` exercises the
/// `.choice` template (Stroop produces choice trials). These tests drive a
/// full session for each of the other 7 templates using the placeholder
/// generator from `Generators.swift`, asserting a `score == 100` finish.
///
/// The placeholder produces a known, trivial response for every template —
/// e.g. the reaction placeholder uses `shouldPress = index % 2 == 0`, the
/// sequence placeholder always answers `["3","7","1"]`, etc. The driver
/// inspects the emitted trial to derive the correct response.
///
/// Drift behavior: templates whose placeholder returns the same answer on
/// every trial (sequence, grid, numberLine, sort, recall) will trip the
/// streak-walk drift detector after the first trial at identical RTs, so
/// we don't assert `drifts == 0` for those. `score == 100` is what matters
/// for the round-trip — drift is a separate, orthogonal concern.
final class EnginePlaceholderTemplateTests: XCTestCase {

    // MARK: - reaction
    // Placeholder: shouldPress = (index % 2 == 0). Game: reaction (20 trials).
    // Per-trial answer alternates, so no streak-walk drift.

    func testReactionTemplateFullSession() async throws {
        let game = Games.game(.reaction)!
        let collector = EventCollector()
        let engine = try Engine(game: game, userIdentifier: "test")

        let driver = Task<SessionResult?, Never> {
            var finish: SessionResult?
            for await event in engine.events {
                switch event {
                case .trial(let trial, _):
                    guard case .reaction(let rt) = trial else { continue }
                    try? await Task.sleep(nanoseconds: UInt64.random(in: 250_000_000...350_000_000))
                    try? await engine.answer(.reaction(rt.shouldPress))
                case .answer(let a):
                    collector.append(.answer(a))
                case .finish(let r):
                    collector.append(.finish(r))
                    finish = r
                }
            }
            return finish
        }

        await engine.start()
        let finish = await driver.value

        XCTAssertNotNil(finish, "reaction should produce a finish event")
        XCTAssertEqual(finish?.gameId, .reaction)
        XCTAssertEqual(finish?.answers.count, game.trials)
        XCTAssertEqual(finish?.score, 100, "All-correct reaction answers should score 100")
        // Alternating responses make streak-walk rare, but two non-adjacent
        // trials with matching RTs (e.g. trial 0 vs trial 2) can still trip it
        // by chance. We only assert score here; drift is orthogonal.
    }

    // MARK: - sequence
    // Placeholder: answer = ["3", "7", "1"] every trial. Game: digitspan (14).
    // Identical response every trial → streak-walk drift after trial 1.

    func testSequenceTemplateFullSession() async throws {
        let game = Games.game(.digitspan)!
        let collector = EventCollector()
        let engine = try Engine(game: game, userIdentifier: "test")

        let driver = Task<SessionResult?, Never> {
            var finish: SessionResult?
            for await event in engine.events {
                switch event {
                case .trial(let trial, _):
                    guard case .sequence(let st) = trial else { continue }
                    try? await Task.sleep(nanoseconds: UInt64.random(in: 250_000_000...350_000_000))
                    try? await engine.answer(.sequence(st.answer))
                case .answer(let a):
                    collector.append(.answer(a))
                case .finish(let r):
                    collector.append(.finish(r))
                    finish = r
                }
            }
            return finish
        }

        await engine.start()
        let finish = await driver.value

        XCTAssertNotNil(finish, "digitspan should produce a finish event")
        XCTAssertEqual(finish?.gameId, .digitspan)
        XCTAssertEqual(finish?.answers.count, game.trials)
        XCTAssertEqual(finish?.score, 100, "All-correct sequence answers should score 100")
    }

    // MARK: - grid
    // Placeholder: answer = GridCell(row: 0, col: 0) every trial. Game: selattn (16).
    // Identical response every trial → streak-walk drift after trial 1.

    func testGridTemplateFullSession() async throws {
        let game = Games.game(.selattn)!
        let collector = EventCollector()
        let engine = try Engine(game: game, userIdentifier: "test")

        let driver = Task<SessionResult?, Never> {
            var finish: SessionResult?
            for await event in engine.events {
                switch event {
                case .trial(let trial, _):
                    guard case .grid(let gt) = trial else { continue }
                    try? await Task.sleep(nanoseconds: UInt64.random(in: 250_000_000...350_000_000))
                    try? await engine.answer(.grid(gt.answer))
                case .answer(let a):
                    collector.append(.answer(a))
                case .finish(let r):
                    collector.append(.finish(r))
                    finish = r
                }
            }
            return finish
        }

        await engine.start()
        let finish = await driver.value

        XCTAssertNotNil(finish, "selattn should produce a finish event")
        XCTAssertEqual(finish?.gameId, .selattn)
        XCTAssertEqual(finish?.answers.count, game.trials)
        XCTAssertEqual(finish?.score, 100, "All-correct grid answers should score 100")
    }

    // MARK: - recall
    // Real paired generator returns a `.recall(RecallTrial)`. We answer with
    // the correct choice's id via the `.recall` response.

    func testRecallTemplateFullSession() async throws {
        let game = Games.game(.paired)!
        let collector = EventCollector()
        let engine = try Engine(game: game, userIdentifier: "test")

        let driver = Task<SessionResult?, Never> {
            var finish: SessionResult?
            for await event in engine.events {
                switch event {
                case .trial(let trial, _):
                    guard case .recall(let rt) = trial else { continue }
                    let correct = rt.choices.first(where: { $0.correct })!
                    try? await Task.sleep(nanoseconds: UInt64.random(in: 250_000_000...350_000_000))
                    try? await engine.answer(.recall(correct.id))
                case .answer(let a):
                    collector.append(.answer(a))
                case .finish(let r):
                    collector.append(.finish(r))
                    finish = r
                }
            }
            return finish
        }

        await engine.start()
        let finish = await driver.value

        XCTAssertNotNil(finish, "paired should produce a finish event")
        XCTAssertEqual(finish?.gameId, .paired)
        XCTAssertEqual(finish?.answers.count, game.trials)
        XCTAssertEqual(finish?.score, 100, "All-correct recall answers should score 100")
    }

    // MARK: - numberLine
    // Placeholder: target = 42, tolerance = 0.05. Game: numline (16).
    // Identical response every trial → streak-walk drift after trial 1.

    func testNumberLineTemplateFullSession() async throws {
        let game = Games.game(.numline)!
        let collector = EventCollector()
        let engine = try Engine(game: game, userIdentifier: "test")

        let driver = Task<SessionResult?, Never> {
            var finish: SessionResult?
            for await event in engine.events {
                switch event {
                case .trial(let trial, _):
                    guard case .numberLine(let nt) = trial else { continue }
                    try? await Task.sleep(nanoseconds: UInt64.random(in: 250_000_000...350_000_000))
                    try? await engine.answer(.numberLine(nt.target))
                case .answer(let a):
                    collector.append(.answer(a))
                case .finish(let r):
                    collector.append(.finish(r))
                    finish = r
                }
            }
            return finish
        }

        await engine.start()
        let finish = await driver.value

        XCTAssertNotNil(finish, "numline should produce a finish event")
        XCTAssertEqual(finish?.gameId, .numline)
        XCTAssertEqual(finish?.answers.count, game.trials)
        XCTAssertEqual(finish?.score, 100, "All-correct numberLine answers should score 100")
    }

    // MARK: - typed
    // Placeholder: answerPattern = ".*" — anything matches. Game: wordlist (1 trial).
    // 1 trial, so no streak-walk possible.

    func testTypedTemplateFullSession() async throws {
        let game = Games.game(.wordlist)!
        let collector = EventCollector()
        let engine = try Engine(game: game, userIdentifier: "test")

        let driver = Task<SessionResult?, Never> {
            var finish: SessionResult?
            for await event in engine.events {
                switch event {
                case .trial(let trial, _):
                    guard case .typed = trial else { continue }
                    try? await Task.sleep(nanoseconds: UInt64.random(in: 250_000_000...350_000_000))
                    try? await engine.answer(.typed("anything"))
                case .answer(let a):
                    collector.append(.answer(a))
                case .finish(let r):
                    collector.append(.finish(r))
                    finish = r
                }
            }
            return finish
        }

        await engine.start()
        let finish = await driver.value

        XCTAssertNotNil(finish, "wordlist should produce a finish event")
        XCTAssertEqual(finish?.gameId, .wordlist)
        XCTAssertEqual(finish?.answers.count, game.trials)
        XCTAssertEqual(finish?.score, 100, "Any typed text should match the .* pattern and score 100")
        XCTAssertEqual(finish?.drifts, 0, "Single trial cannot trip the drift detector")
    }

    // MARK: - sort
    // Placeholder: answerIndex = 0 every trial. Game: towers (8).
    // Identical response every trial → streak-walk drift after trial 1.

    func testSortTemplateFullSession() async throws {
        let game = Games.game(.towers)!
        let collector = EventCollector()
        let engine = try Engine(game: game, userIdentifier: "test")

        let driver = Task<SessionResult?, Never> {
            var finish: SessionResult?
            for await event in engine.events {
                switch event {
                case .trial(let trial, _):
                    guard case .sort(let st) = trial else { continue }
                    try? await Task.sleep(nanoseconds: UInt64.random(in: 250_000_000...350_000_000))
                    try? await engine.answer(.sort(st.answerIndex))
                case .answer(let a):
                    collector.append(.answer(a))
                case .finish(let r):
                    collector.append(.finish(r))
                    finish = r
                }
            }
            return finish
        }

        await engine.start()
        let finish = await driver.value

        XCTAssertNotNil(finish, "towers should produce a finish event")
        XCTAssertEqual(finish?.gameId, .towers)
        XCTAssertEqual(finish?.answers.count, game.trials)
        XCTAssertEqual(finish?.score, 100, "All-correct sort answers should score 100")
    }
}
