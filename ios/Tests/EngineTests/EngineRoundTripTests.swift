import XCTest
@testable import Upmind

final class EngineRoundTripTests: XCTestCase {

    func testStroopSessionProducesFinishEventWithExpectedScore() async throws {
        let game = Games.game(.stroop)!
        let mockClock = MockClock()
        let collector = EventCollector()
        let engine = try Engine(game: game, userIdentifier: "test", clock: mockClock)
        let consumeTask = Task {
            for await event in engine.events {
                collector.append(event)
            }
        }
        await engine.start()
        // Drive 20 trials; the choice id 'red' / 'green' / 'blue' / 'yellow' is the ink.
        // We don't know the correct one ahead of time, so we capture it from the trial.
        // The mock clock advances 20–50ms per trial so RTs are realistic
        // (well above the 180ms drift floor) and the whole test runs instantly.
        var rng = SeededRNG(seed: 1)
        for _ in 0..<game.trials {
            let lastTrial = collector.lastTrial()
            guard case .choice(let ct) = lastTrial else { XCTFail(); return }
            let correct = ct.choices.first(where: { $0.correct })!
            mockClock.advance(by: .milliseconds(20 + rng.int(upperBound: 30)))
            try await engine.answer(.choice(correct.id))
        }
        let finish = collector.lastFinish()
        consumeTask.cancel()
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
        let mockClock = MockClock()
        let collector = EventCollector()
        let engine = try Engine(game: game, userIdentifier: "test", clock: mockClock)
        let consumeTask = Task {
            for await event in engine.events {
                collector.append(event)
            }
        }
        await engine.start()
        for _ in 0..<game.trials {
            let lastTrial = collector.lastTrial()
            guard case .choice(let ct) = lastTrial else { XCTFail(); return }
            let wrong = ct.choices.first(where: { !$0.correct })!
            mockClock.advance(by: .milliseconds(50))
            try await engine.answer(.choice(wrong.id))
        }
        let finish = collector.lastFinish()
        consumeTask.cancel()
        XCTAssertNotNil(finish)
        XCTAssertEqual(finish?.score, 0)
        XCTAssertEqual(finish?.accuracy, 0)
    }

    func testAbortingSessionFinishesWithoutScore() async throws {
        let game = Games.game(.stroop)!
        let mockClock = MockClock()
        let collector = EventCollector()
        let engine = try Engine(game: game, userIdentifier: "test", clock: mockClock)
        let consumeTask = Task {
            for await event in engine.events {
                collector.append(event)
            }
        }
        await engine.start()
        await engine.abort()
        consumeTask.cancel()
        // After abort, a new answer should be rejected.
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

/// Deterministic clock. Time only advances when `advance(by:)` is called;
/// `sleep(for:)` advances the clock instantly without real-time delay.
final class MockClock: Clock, @unchecked Sendable {
    typealias Duration = ContinuousClock.Duration
    private let lock = NSLock()
    private var _now: ContinuousClock.Instant

    init() {
        self._now = ContinuousClock().now
    }

    var now: ContinuousClock.Instant {
        lock.lock()
        defer { lock.unlock() }
        return _now
    }

    func advance(by duration: Duration) {
        lock.lock()
        _now = _now.advanced(by: duration)
        lock.unlock()
    }

    func sleep(for duration: Duration) async throws {
        advance(by: duration)
    }

    func sleep(until deadline: ContinuousClock.Instant, tolerance: Duration?) async throws {
        let delta: Duration
        lock.lock()
        delta = deadline - _now
        lock.unlock()
        advance(by: delta)
    }
}

/// Thread-safe collector for events emitted by the Engine on its AsyncStream.
/// Wraps an internal lock so consumers can read snapshots without races.
final class EventCollector: @unchecked Sendable {
    private let lock = NSLock()
    private var trials: [(Trial, Int)] = []
    private var answers: [AnswerRecord] = []
    private var finishes: [SessionResult] = []

    func append(_ event: Engine.Event) {
        lock.lock(); defer { lock.unlock() }
        switch event {
        case .trial(let t, let i): trials.append((t, i))
        case .answer(let a):       answers.append(a)
        case .finish(let r):       finishes.append(r)
        }
    }

    func lastTrial() -> Trial? {
        lock.lock(); defer { lock.unlock() }
        return trials.last?.0
    }

    func lastFinish() -> SessionResult? {
        lock.lock(); defer { lock.unlock() }
        return finishes.last
    }
}
