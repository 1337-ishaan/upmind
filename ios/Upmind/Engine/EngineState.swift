import Foundation

/// Mutable engine state. Lives behind the `Engine` actor — never exposed.
struct EngineState: Sendable {
    var game: GameDef
    var difficulty: Int
    var trials: [Trial]
    var answers: [AnswerRecord]
    var currentIndex: Int
    /// Wall-clock start of the session. Display-only (used for `SessionResult.startedAt`).
    var startTime: Date
    /// `ContinuousClock` instant the session started. Reserved for future total-duration
    /// calculations; per-trial RT uses `trialStartInstant`.
    var startTimeInstant: ContinuousClock.Instant
    /// `ContinuousClock` instant the current trial started. Used for per-trial RT.
    var trialStartInstant: ContinuousClock.Instant
    var isFinished: Bool
    var isStarted: Bool
    var drifts: Int
    /// Stable session identifier. Generated once at engine init, included in `SessionResult`.
    var sessionId: UUID
    /// Anonymous device/user identifier. Resolved to a Supabase user id in Plan 3.
    var userIdentifier: String

    init(game: GameDef, userIdentifier: String = "anonymous") {
        let clock = ContinuousClock()
        self.game = game
        self.difficulty = 1
        self.trials = []
        self.answers = []
        self.currentIndex = 0
        self.startTime = .distantPast
        self.startTimeInstant = clock.now
        self.trialStartInstant = clock.now
        self.isFinished = false
        self.isStarted = false
        self.drifts = 0
        self.sessionId = UUID()
        self.userIdentifier = userIdentifier
    }
}
