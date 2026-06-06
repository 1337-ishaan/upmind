import Foundation

/// The 42 cognitive-training games. The `rawValue` matches the
/// string used in the existing React Native catalog (`src/features/games/catalog.ts`)
/// so analytics events stay stable across the migration.
enum GameId: String, CaseIterable, Codable, Sendable, Hashable, Identifiable {
    // Attention
    case stroop, flanker, gongo, conswitch, selattn, divattn, reaction
    // Memory
    case digitspan, corsi, spatialspan, paired, wordlist, picrecog, nback
    // Processing
    case symboldigit, canceltask, trailnum, patterncomp, lettercomp
    // Numeracy
    case mentalmath, numline, estimation, quantity, numestimate, arithmeticv, fraction
    // Verbal
    case synonyms, analogies, sentence, vocab, verbfluency, category
    // Problem
    case matrix, logic, mentalrot, matchpairs, towers
    // Executive (premium)
    case trailmix, rulefind, setshift, planning, inhibit

    var id: String { rawValue }

    /// Executive-function games are gated behind the `upmind_premium` entitlement.
    var isPremium: Bool {
        switch self {
        case .trailmix, .rulefind, .setshift, .planning, .inhibit:
            return true
        default:
            return false
        }
    }
}
