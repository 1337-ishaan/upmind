import XCTest
@testable import Upmind

final class EngineRoundTripTests: XCTestCase {

    func testStroopSessionProducesFinishEventWithExpectedScore() async throws {
        let game = Games.game(.stroop)!
        let collector = EventCollector()
        let engine = try Engine(game: game, userIdentifier: "test")

        // Drive the engine from the consumer side. We iterate the event
        // stream and, for every `.trial`, look up the correct choice and
        // call `engine.answer` — no race with the consumer because we're
        // the only consumer. The artificial per-trial sleep keeps RTs
        // above the 180ms drift floor and varied enough to avoid the
        // streak-walk detector.
        let driver = Task<SessionResult?, Never> {
            var finish: SessionResult?
            for await event in engine.events {
                switch event {
                case .trial(let trial, _):
                    guard case .choice(let ct) = trial else { continue }
                    let correct = ct.choices.first(where: { $0.correct })!
                    // 250–350ms per trial: above the 180ms floor, below 5s
                    // total for 20 trials.
                    try? await Task.sleep(nanoseconds: UInt64.random(in: 250_000_000...350_000_000))
                    try? await engine.answer(.choice(correct.id))
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

        XCTAssertNotNil(finish, "Engine should have finished after 20 trials")
        XCTAssertEqual(finish?.gameId, .stroop)
        XCTAssertEqual(finish?.answers.count, 20)
        XCTAssertEqual(finish?.score, 100, "All-correct answers should produce a perfect score")
        XCTAssertEqual(finish?.drifts, 0, "No drift should be detected with realistic RTs")
        XCTAssertNotNil(finish?.sessionId, "SessionResult must carry a session id")
        XCTAssertEqual(finish?.userIdentifier, "test")
    }

    func testWrongAnswerReducesScore() async throws {
        let game = Games.game(.stroop)!
        let collector = EventCollector()
        let engine = try Engine(game: game, userIdentifier: "test")

        let driver = Task<SessionResult?, Never> {
            var finish: SessionResult?
            for await event in engine.events {
                switch event {
                case .trial(let trial, _):
                    guard case .choice(let ct) = trial else { continue }
                    let wrong = ct.choices.first(where: { !$0.correct })!
                    try? await Task.sleep(nanoseconds: UInt64.random(in: 250_000_000...350_000_000))
                    try? await engine.answer(.choice(wrong.id))
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

        XCTAssertNotNil(finish)
        XCTAssertEqual(finish?.score, 0)
        XCTAssertEqual(finish?.accuracy, 0)
    }

    func testAbortingSessionFinishesWithoutScore() async throws {
        let game = Games.game(.stroop)!
        let engine = try Engine(game: game, userIdentifier: "test")

        // Drain the stream so the engine can emit freely.
        let drain = Task {
            for await _ in engine.events { }
        }
        await engine.start()
        await engine.abort()
        drain.cancel()

        do {
            try await engine.answer(.choice("anything"))
            XCTFail("Should have thrown")
        } catch EngineError.sessionAlreadyFinished {
            // expected
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }
}

// MARK: - Test helpers

/// Thread-safe collector for events emitted by the Engine on its AsyncStream.
/// Wraps an internal lock so consumers can read snapshots without races.
final class EventCollector: @unchecked Sendable {
    private let lock = NSLock()
    private var answers: [AnswerRecord] = []
    private var finishes: [SessionResult] = []

    func append(_ event: _CollectorEvent) {
        lock.lock(); defer { lock.unlock() }
        switch event {
        case .answer(let a): answers.append(a)
        case .finish(let r): finishes.append(r)
        }
    }
}

enum _CollectorEvent {
    case answer(AnswerRecord)
    case finish(SessionResult)
}
