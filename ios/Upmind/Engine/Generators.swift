import Foundation

/// The registry of all 42 game generators. Each `GameId` maps to a single
/// generator implementation that produces deterministic trials. Plan 1
/// shipped placeholders; Plan 2 Round 4 replaced them with real ones.
///
/// The concrete generator structs live in the `Generators/` subfolder,
/// grouped one file per construct (AttentionGenerators, MemoryGenerators,
/// ProcessingGenerators, NumeracyGenerators, VerbalGenerators,
/// ProblemGenerators, ExecutiveGenerators).
enum Generators {

    /// Convenience handle for the Stroop generator, kept so the existing
    /// `GeneratorTests.swift` (which references `Generators.realStroop`)
    /// continues to compile without modification.
    static let realStroop: any TrialGenerator = AttentionGenerators.Stroop

    /// Look up the generator for a given game id. Returns `nil` only when
    /// the id is not registered (which, with all 42 cases switched below,
    /// is unreachable — the compiler enforces exhaustiveness).
    static func lookup(_ id: GameId) -> TrialGenerator? {
        switch id {
        // Attention (7)
        case .stroop:    return AttentionGenerators.Stroop
        case .flanker:   return AttentionGenerators.Flanker
        case .gongo:     return AttentionGenerators.GoNoGo
        case .conswitch: return AttentionGenerators.ContextSwitch
        case .selattn:   return AttentionGenerators.VisualSearch
        case .divattn:   return AttentionGenerators.DividedAttention
        case .reaction:  return AttentionGenerators.SimpleReaction

        // Memory (7)
        case .digitspan:   return MemoryGenerators.DigitSpan
        case .corsi:       return MemoryGenerators.CorsiBlocks
        case .spatialspan: return MemoryGenerators.SpatialSpan
        case .paired:      return MemoryGenerators.PairedAssociate
        case .wordlist:    return MemoryGenerators.WordList
        case .picrecog:    return MemoryGenerators.PictureRecognition
        case .nback:       return MemoryGenerators.NBack

        // Processing (5)
        case .symboldigit: return ProcessingGenerators.SymbolDigit
        case .canceltask:  return ProcessingGenerators.Cancellation
        case .trailnum:    return ProcessingGenerators.TrailMakingA
        case .patterncomp: return ProcessingGenerators.PatternComparison
        case .lettercomp:  return ProcessingGenerators.LetterComparison

        // Numeracy (7)
        case .mentalmath:  return NumeracyGenerators.MentalMath
        case .numline:     return NumeracyGenerators.NumberLine
        case .estimation:  return NumeracyGenerators.Estimation
        case .quantity:    return NumeracyGenerators.Quantity
        case .numestimate: return NumeracyGenerators.NumberEstimate
        case .arithmeticv: return NumeracyGenerators.ArithmeticVerify
        case .fraction:    return NumeracyGenerators.FractionCompare

        // Verbal (6)
        case .synonyms:    return VerbalGenerators.Synonyms
        case .analogies:   return VerbalGenerators.Analogies
        case .sentence:    return VerbalGenerators.SentenceComplete
        case .vocab:       return VerbalGenerators.Vocabulary
        case .verbfluency: return VerbalGenerators.VerbalFluency
        case .category:    return VerbalGenerators.CategoryFluency

        // Problem-Solving (5)
        case .matrix:     return ProblemGenerators.MatrixReasoning
        case .logic:      return ProblemGenerators.Logic
        case .mentalrot:  return ProblemGenerators.MentalRotation
        case .matchpairs: return ProblemGenerators.PatternMatch
        case .towers:     return ProblemGenerators.TowerOfHanoi

        // Executive (5, premium)
        case .trailmix: return ExecutiveGenerators.TrailMakingB
        case .rulefind: return ExecutiveGenerators.RuleFinding
        case .setshift: return ExecutiveGenerators.SetShifting
        case .planning: return ExecutiveGenerators.Planning
        case .inhibit:  return ExecutiveGenerators.Inhibition
        }
    }
}
