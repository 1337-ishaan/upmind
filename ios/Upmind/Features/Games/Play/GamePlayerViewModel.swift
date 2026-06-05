import Foundation
import Observation

/// Drives the `GamePlayerView` for one session. Owns the `Engine`,
/// consumes its event stream, exposes the current trial + result to the
/// view, and forwards user answers back to the engine.
///
/// The VM is `@MainActor`-isolated: SwiftUI views read `state` from the
/// main thread, and the event consumer hops to the main actor before
/// mutating `state` via `handle(_:)`.
@MainActor
@Observable
final class GamePlayerViewModel {

    /// The screen states the view can render. `.playing` carries the
    /// current trial plus the `lastCorrect` verdict (nil until the user
    /// answers the visible trial).
    enum State: Equatable {
        case loading
        case playing(trial: Trial, index: Int, total: Int, lastCorrect: Bool?)
        case finished(SessionResult)
        case error(String)
    }

    var state: State = .loading

    private let game: GameDef
    private let engine: Engine
    private var consumeTask: Task<Void, Never>?

    init(game: GameDef, userIdentifier: String = "anonymous") throws {
        self.game = game
        self.engine = try Engine(game: game, userIdentifier: userIdentifier)
    }

    /// Start the engine and begin consuming events. Idempotent: re-calling
    /// after a successful start is a no-op (the engine guards against
    /// double-starts; the VM only spawns one consumer task).
    func start() {
        guard consumeTask == nil else { return }
        consumeTask = Task { [weak self] in
            guard let self else { return }
            await self.engine.start()
            for await event in self.engine.events {
                self.handle(event)
            }
        }
    }

    /// Send a user answer back to the engine. The engine will emit
    /// `.answer` and (if it was the last trial) `.finish`; we update
    /// `state` from those events.
    func answer(_ response: TrialResponse) async {
        do {
            try await engine.answer(response)
        } catch {
            state = .error("Engine error: \(error.localizedDescription)")
        }
    }

    /// Abort the session. The view can call this from a "Quit" button.
    /// Safe to call multiple times; safe to call before `start()`.
    func abort() {
        Task { [weak self] in
            await self?.engine.abort()
            self?.consumeTask?.cancel()
            self?.consumeTask = nil
        }
    }

    private func handle(_ event: Engine.Event) {
        switch event {
        case .trial(let trial, let index):
            // Keep the prior `total` if we were already playing; otherwise
            // fall back to the game's declared trial count.
            let total = state.playingTotal ?? game.trials
            state = .playing(trial: trial, index: index, total: total, lastCorrect: nil)
        case .answer(let record):
            // Show feedback for the just-answered trial by re-emitting the
            // same trial+index with `lastCorrect` set.
            if case .playing(let trial, let index, let total, _) = state {
                state = .playing(trial: trial, index: index, total: total, lastCorrect: record.correct)
            }
        case .finish(let result):
            state = .finished(result)
            consumeTask?.cancel()
            consumeTask = nil
        }
    }
}

private extension GamePlayerViewModel.State {
    /// Helper to read the `total` value out of a `.playing` case.
    var playingTotal: Int? {
        if case .playing(_, _, let total, _) = self { return total }
        return nil
    }
}
