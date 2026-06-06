import Foundation

enum EngineError: Error, LocalizedError, Sendable {
    case unknownGame(String)
    case noActiveTrial
    case sessionAlreadyFinished
    case duplicateAnswer
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .unknownGame(let id):
            return "No game with id '\(id)' is registered."
        case .noActiveTrial:
            return "There is no active trial to answer."
        case .sessionAlreadyFinished:
            return "This session has already finished."
        case .duplicateAnswer:
            return "An answer was already recorded for this trial."
        case .invalidResponse:
            return "The response does not match the trial's expected shape."
        }
    }
}
