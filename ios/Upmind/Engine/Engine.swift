import Foundation

/// Drives one cognitive-training session. The engine is framework-agnostic
/// (no SwiftUI / UIKit imports) so it can be tested in isolation and
/// potentially reused on a watchOS app later.
actor Engine {

    enum Event: Sendable {
        case trial(Trial, index: Int)
        case answer(AnswerRecord)
        case finish(SessionResult)
    }

    private(set) var state: EngineState

    /// Stream of events emitted during the session. Consumers iterate with
    /// `for await event in engine.events`. Yielded non-blockingly from inside
    /// the actor; consumers never need to `await` an emit.
    private let eventStream: AsyncStream<Event>
    private let eventContinuation: AsyncStream<Event>.Continuation

    /// Drift floor: reaction times below 180ms are flagged as impossible-human.
    /// (Humans don't go faster than ~200ms for simple visual RT.)
    private let rtImpossibleFloorMs: Int = 180
    /// Drift streak cap: walk back at most this many prior answers when looking
    /// for a streak of identical RT + response.
    private let driftStreakCap: Int = 5
    /// Aggregate flag: a session whose median RT sits below this threshold is
    /// impossibly fast, so we add one extra drift to the count.
    private let aggregateMedianFloorMs: Int = 250

    init(
        game: GameDef,
        userIdentifier: String = "anonymous"
    ) throws {
        guard Games.game(game.id) != nil else {
            throw EngineError.unknownGame(game.id.rawValue)
        }
        self.state = EngineState(game: game, userIdentifier: userIdentifier)
        let (stream, continuation) = AsyncStream<Event>.makeStream()
        self.eventStream = stream
        self.eventContinuation = continuation
    }

    /// Public stream of events. Iterate from the UI / ViewModel with
    /// `for await event in engine.events { ... }`.
    nonisolated var events: AsyncStream<Event> { eventStream }

    // MARK: - Lifecycle

    func start() async {
        guard !state.isStarted, !state.isFinished else { return }
        guard let generator = Generators.lookup(state.game.id) else {
            state.isFinished = true
            return
        }
        var trials: [Trial] = []
        trials.reserveCapacity(state.game.trials)
        for i in 0..<state.game.trials {
            trials.append(generator.makeTrial(index: i, difficulty: state.difficulty))
        }
        state.trials = trials
        state.isStarted = true
        state.startTime = Date()
        state.trialStart = ContinuousClock.now
        emitNextTrial()
    }

    func answer(_ response: TrialResponse) async throws {
        guard state.isStarted else { throw EngineError.noActiveTrial }
        guard !state.isFinished else { throw EngineError.sessionAlreadyFinished }
        guard state.currentIndex < state.trials.count else {
            throw EngineError.duplicateAnswer
        }
        let trial = state.trials[state.currentIndex]
        let now = ContinuousClock.now
        let elapsed = now - state.trialStart
        let rtMs = Self.durationToMs(elapsed)
        let correct = try isCorrect(trial: trial, response: response)
        let drift = detectDrift(rtMs: rtMs, response: response)
        if drift { state.drifts += 1 }
        let record = AnswerRecord(
            trialIndex: state.currentIndex,
            rtMs: rtMs,
            correct: correct,
            response: response,
            drift: drift
        )
        state.answers.append(record)
        eventContinuation.yield(.answer(record))
        state.currentIndex += 1
        if state.currentIndex >= state.trials.count {
            finish()
        } else {
            emitNextTrial()
        }
    }

    func abort() {
        state.isFinished = true
        eventContinuation.finish()
    }

    // MARK: - Private

    private func emitNextTrial() {
        state.trialStart = ContinuousClock.now
        let trial = state.trials[state.currentIndex]
        eventContinuation.yield(.trial(trial, index: state.currentIndex))
    }

    private func finish() {
        state.isFinished = true
        let finishedAt = Date()
        let correctCount = state.answers.filter(\.correct).count
        let rts = state.answers.map(\.rtMs)
        let medianRt = Scoring.median(rts)
        // Aggregate flag: if the whole session sits below the human floor,
        // count one extra drift.
        if medianRt > 0, medianRt < aggregateMedianFloorMs {
            state.drifts += 1
        }
        let breakdown = Scoring.score(
            correct: correctCount,
            total: state.answers.count,
            rtMedianMs: medianRt,
            rtStddevMs: Scoring.standardDeviation(rts),
            drifts: state.drifts
        )
        let result = SessionResult(
            sessionId: state.sessionId,
            userIdentifier: state.userIdentifier,
            gameId: state.game.id,
            construct: state.game.construct,
            startedAt: state.startTime,
            finishedAt: finishedAt,
            trials: state.trials,
            answers: state.answers,
            score: breakdown.score,
            rtMedianMs: breakdown.rtMedianMs,
            rtStddevMs: breakdown.rtStddevMs,
            accuracy: breakdown.accuracy,
            drifts: breakdown.drifts
        )
        eventContinuation.yield(.finish(result))
        eventContinuation.finish()
    }

    /// Convert a `Duration` (from `ContinuousClock`) to milliseconds.
    private static func durationToMs(_ duration: Duration) -> Int {
        let comps = duration.components
        let totalSeconds = Double(comps.seconds) + Double(comps.attoseconds) / 1e18
        return Int((totalSeconds * 1000).rounded())
    }

    /// Determines whether `response` is the correct answer for `trial`.
    /// Throws `EngineError.invalidResponse` if the response shape does not
    /// match the trial's template. This is a programming bug, not a user
    /// error — it should be caught in development, not silently scored wrong.
    private func isCorrect(trial: Trial, response: TrialResponse) throws -> Bool {
        switch (trial, response) {
        case (.choice(let t), .choice(let id)):
            return t.choices.first(where: { $0.id == id })?.correct ?? false
        case (.recall(let t), .recall(let id)):
            return t.choices.first(where: { $0.id == id })?.correct ?? false
        case (.reaction(let t), .reaction(let pressed)):
            return pressed == t.shouldPress
        case (.sequence(let t), .sequence(let user)):
            guard user.count == t.answer.count else { return false }
            return zip(user, t.answer).allSatisfy { $0 == $1 }
        case (.grid(let t), .grid(let cell)):
            return cell.row == t.answer.row && cell.col == t.answer.col
        case (.numberLine(let t), .numberLine(let v)):
            let span = t.max - t.min
            return abs(v - t.target) <= span * t.tolerance
        case (.typed(let t), .typed(let user)):
            let trimmed = user.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return (try? NSRegularExpression(pattern: t.answerPattern, options: [.caseInsensitive]))
                .map { rx in
                    let range = NSRange(trimmed.startIndex..., in: trimmed)
                    return rx.firstMatch(in: trimmed, range: range) != nil
                } ?? false
        case (.sort(let t), .sort(let idx)):
            return idx == t.answerIndex
        default:
            // Response shape doesn't match the trial template — a programming
            // bug. We throw rather than returning false so a dev catches it.
            throw EngineError.invalidResponse
        }
    }

    private func detectDrift(rtMs: Int, response: TrialResponse) -> Bool {
        if rtMs < rtImpossibleFloorMs { return true }
        // Streak walk: if any of the last `driftStreakCap` answers have the
        // same RT and response, flag the current trial. A bot or "next" key
        // spammer produces this pattern; a human rarely does.
        for prior in state.answers.reversed().prefix(driftStreakCap) {
            if prior.rtMs == rtMs && prior.response == response {
                return true
            }
        }
        return false
    }
}
