import Foundation

/// Mutable engine state. Lives behind the `Engine` actor — never exposed.
struct EngineState: Sendable {
    var game: GameDef
    var difficulty: Int
    var trials: [Trial]
    var answers: [AnswerRecord]
    var currentIndex: Int
    /// Wall-clock start of the session. Display-only (used for `SessionResult.startedAt`).
    /// Wall-clock start of the session. Display-only (used for `SessionResult.startedAt`).
    var startTime: Date
    /// `ContinuousClock.Instant` the current trial started. Used for per-trial RT
    /// (no wall-clock skew). Reset on every emitted trial.
    var trialStart: ContinuousClock.Instant
    var isFinished: Bool
    var isStarted: Bool
    var drifts: Int
    /// Stable session identifier. Generated once at engine init, included in `SessionResult`.
    var sessionId: UUID
    /// Anonymous device/user identifier. Resolved to a Supabase user id in Plan 3.
    var userIdentifier: String

    init(game: GameDef, userIdentifier: String = "anonymous") {
        self.game = game
        self.difficulty = 1
        self.trials = []
        self.answers = []
        self.currentIndex = 0
        self.startTime = .distantPast
        self.trialStart = ContinuousClock.now
        self.isFinished = false
        self.isStarted = false
        self.drifts = 0
        self.sessionId = UUID()
        self.userIdentifier = userIdentifier
    }
}
