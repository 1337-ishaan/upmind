import Foundation

// MARK: - Template

/// The eight trial shapes. Mirrors the React Native engine 1:1.
/// `type` is renamed to `typed` because `type` is a reserved Swift keyword.
enum TemplateKind: String, CaseIterable, Codable, Sendable, Equatable {
    case choice
    case reaction
    case sequence
    case grid
    case recall
    case numberLine = "numberline"
    case typed      = "type"
    case sort
}

// MARK: - Choice

struct Choice: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let label: String
    let correct: Bool
}

struct ChoiceTrial: Sendable, Equatable, Identifiable {
    let id: UUID
    let index: Int
    let difficulty: Int
    let prompt: String
    let choices: [Choice]
    /// Optional sub-mode tag (e.g. "forward" | "backward" for digit span).
    let mode: String?
}

// MARK: - Reaction

struct ReactionTrial: Sendable, Equatable, Identifiable {
    let id: UUID
    let index: Int
    let difficulty: Int
    let prompt: String
    let signal: String
    /// Whether the user should respond at all (false = withhold trial).
    let shouldPress: Bool
    /// Minimum inter-trial interval in ms before the signal can appear.
    let minDelayMs: Int
    /// Maximum inter-trial interval in ms.
    let maxDelayMs: Int
    /// Which channel the signal is delivered on.
    let channel: ReactionChannel
}

enum ReactionChannel: String, Codable, Sendable, Equatable {
    case visual, audio, either
}

// MARK: - Sequence

struct SequenceTrial: Sendable, Equatable, Identifiable {
    let id: UUID
    let index: Int
    let difficulty: Int
    let items: [SequenceItem]
    /// The correct recall (in order). For digit span, may be reversed.
    let answer: [String]
    /// Per-item show time in ms.
    let showMs: Int
    let prompt: String?
    let choices: [String]?
}

enum SequenceItem: Codable, Sendable, Equatable {
    case digit(String)
    case block(row: Int, col: Int, gridSize: Int)

    var key: String {
        switch self {
        case .digit(let d):    return d
        case .block(let r, let c, _): return "\(r):\(c)"
        }
    }
}

// MARK: - Grid

struct GridTrial: Sendable, Equatable, Identifiable {
    let id: UUID
    let index: Int
    let difficulty: Int
    let prompt: String
    let rows: Int
    let cols: Int
    /// Cell labels (string or empty).
    let cells: [[String]]
    let answer: GridCell
    /// Optional target letter or shape to highlight.
    let target: String?
}

struct GridCell: Codable, Sendable, Equatable {
    let row: Int
    let col: Int
}

// MARK: - Recall

struct RecallTrial: Sendable, Equatable, Identifiable {
    let id: UUID
    let index: Int
    let difficulty: Int
    let prompt: String
    let choices: [Choice]
    /// The id of the correct choice.
    let correctId: String
}

// MARK: - NumberLine

struct NumberLineTrial: Sendable, Equatable, Identifiable {
    let id: UUID
    let index: Int
    let difficulty: Int
    let prompt: String
    let min: Double
    let max: Double
    let target: Double
    /// Snapping tolerance as a fraction of (max - min). Default 0.05.
    let tolerance: Double
}

// MARK: - Typed

struct TypedTrial: Sendable, Equatable, Identifiable {
    let id: UUID
    let index: Int
    let difficulty: Int
    let prompt: String
    let placeholder: String?
    /// Acceptable answers as a regex source string.
    let answerPattern: String
}

// MARK: - Sort

struct SortTrial: Sendable, Equatable, Identifiable {
    let id: UUID
    let index: Int
    let difficulty: Int
    let item: String
    let categories: [String]
    let answerIndex: Int
}

// MARK: - Trial enum

/// The trial envelope passed to renderers. Renderers `switch` on the case
/// to get the correct associated value.
enum Trial: Sendable, Equatable, Identifiable {
    case choice(ChoiceTrial)
    case reaction(ReactionTrial)
    case sequence(SequenceTrial)
    case grid(GridTrial)
    case recall(RecallTrial)
    case numberLine(NumberLineTrial)
    case typed(TypedTrial)
    case sort(SortTrial)

    var id: UUID {
        switch self {
        case .choice(let t):     return t.id
        case .reaction(let t):   return t.id
        case .sequence(let t):   return t.id
        case .grid(let t):       return t.id
        case .recall(let t):     return t.id
        case .numberLine(let t): return t.id
        case .typed(let t):      return t.id
        case .sort(let t):       return t.id
        }
    }

    var index: Int {
        switch self {
        case .choice(let t):     return t.index
        case .reaction(let t):   return t.index
        case .sequence(let t):   return t.index
        case .grid(let t):       return t.index
        case .recall(let t):     return t.index
        case .numberLine(let t): return t.index
        case .typed(let t):      return t.index
        case .sort(let t):       return t.index
        }
    }

    var difficulty: Int {
        switch self {
        case .choice(let t):     return t.difficulty
        case .reaction(let t):   return t.difficulty
        case .sequence(let t):   return t.difficulty
        case .grid(let t):       return t.difficulty
        case .recall(let t):     return t.difficulty
        case .numberLine(let t): return t.difficulty
        case .typed(let t):      return t.difficulty
        case .sort(let t):       return t.difficulty
        }
    }

    var template: TemplateKind {
        switch self {
        case .choice:               return .choice
        case .reaction:             return .reaction
        case .sequence:             return .sequence
        case .grid:                 return .grid
        case .recall:               return .recall
        case .numberLine:           return .numberLine
        case .typed:                return .typed
        case .sort:                 return .sort
        }
    }
}
