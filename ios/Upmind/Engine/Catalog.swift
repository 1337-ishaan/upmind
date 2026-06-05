import Foundation

struct GameDef: Sendable, Hashable, Identifiable {
    let id: GameId
    let name: String
    let construct: Construct
    let template: TemplateKind
    let trials: Int
    let description: String
    let isPremium: Bool
}

enum Games {

    static let all: [GameDef] = [
        // ── Attention (7) ──
        .init(id: .stroop,     name: "Stroop",             construct: .attention,  template: .choice,     trials: 20, description: "Name the ink color",                        isPremium: false),
        .init(id: .flanker,    name: "Flanker Focus",      construct: .attention,  template: .choice,     trials: 20, description: "Target arrow with distractors",              isPremium: false),
        .init(id: .gongo,      name: "Go / No-Go",         construct: .attention,  template: .reaction,   trials: 30, description: "Press for animals only",                     isPremium: false),
        .init(id: .conswitch,  name: "Context Switch",     construct: .attention,  template: .choice,     trials: 20, description: "Switch between rules",                       isPremium: false),
        .init(id: .selattn,    name: "Visual Search",      construct: .attention,  template: .grid,       trials: 16, description: "Find the target letter",                     isPremium: false),
        .init(id: .divattn,    name: "Divided Attention",  construct: .attention,  template: .reaction,   trials: 24, description: "Dual-channel task",                          isPremium: false),
        .init(id: .reaction,   name: "Simple Reaction",    construct: .attention,  template: .reaction,   trials: 20, description: "Tap on signal",                              isPremium: false),

        // ── Memory (7) ──
        .init(id: .digitspan,    name: "Digit Span",         construct: .memory,    template: .sequence,  trials: 14, description: "Repeat sequences",                          isPremium: false),
        .init(id: .corsi,        name: "Corsi Blocks",       construct: .memory,    template: .sequence,  trials: 14, description: "Tap blocks in order",                       isPremium: false),
        .init(id: .spatialspan,  name: "Spatial Span",       construct: .memory,    template: .sequence,  trials: 12, description: "Remember positions",                        isPremium: false),
        .init(id: .paired,       name: "Paired Associate",   construct: .memory,    template: .recall,    trials: 16, description: "Recall word pairs",                         isPremium: false),
        .init(id: .wordlist,     name: "Word List",          construct: .memory,    template: .typed,     trials: 1,  description: "Type remembered words",                     isPremium: false),
        .init(id: .picrecog,     name: "Picture Recognition",construct: .memory,    template: .choice,    trials: 20, description: "Seen before?",                              isPremium: false),
        .init(id: .nback,        name: "N-Back",             construct: .memory,    template: .choice,    trials: 16, description: "2-back match detection",                    isPremium: false),

        // ── Processing (5) ──
        .init(id: .symboldigit,  name: "Symbol-Digit",       construct: .processing,template: .choice,    trials: 24, description: "Match symbols to digits",                   isPremium: false),
        .init(id: .canceltask,   name: "Cancellation",       construct: .processing,template: .grid,      trials: 1,  description: "Cross out targets",                         isPremium: false),
        .init(id: .trailnum,     name: "Trail Making A",     construct: .processing,template: .grid,      trials: 1,  description: "Connect 1→2→3",                             isPremium: false),
        .init(id: .patterncomp,  name: "Pattern Comparison", construct: .processing,template: .choice,    trials: 20, description: "Same or different?",                        isPremium: false),
        .init(id: .lettercomp,   name: "Letter Comparison",  construct: .processing,template: .choice,    trials: 20, description: "Strings identical?",                        isPremium: false),

        // ── Numeracy (7) ──
        .init(id: .mentalmath,   name: "Mental Math",        construct: .numeracy,  template: .choice,    trials: 20, description: "Arithmetic problems",                       isPremium: false),
        .init(id: .numline,      name: "Number Line",        construct: .numeracy,  template: .numberLine,trials: 16, description: "Place a number",                            isPremium: false),
        .init(id: .estimation,   name: "Estimation",         construct: .numeracy,  template: .choice,    trials: 16, description: "Approximate product",                       isPremium: false),
        .init(id: .quantity,     name: "Quantity",           construct: .numeracy,  template: .choice,    trials: 16, description: "Which is more?",                            isPremium: false),
        .init(id: .numestimate,  name: "Number Estimate",    construct: .numeracy,  template: .numberLine,trials: 16, description: "Estimate count",                            isPremium: false),
        .init(id: .arithmeticv,  name: "Arithmetic Verify",  construct: .numeracy,  template: .choice,    trials: 20, description: "Correct equation?",                         isPremium: false),
        .init(id: .fraction,     name: "Fraction Compare",   construct: .numeracy,  template: .choice,    trials: 16, description: "Larger fraction?",                          isPremium: false),

        // ── Verbal (6) ──
        .init(id: .synonyms,     name: "Synonyms",           construct: .verbal,    template: .choice,    trials: 20, description: "Word meaning match",                        isPremium: false),
        .init(id: .analogies,    name: "Analogies",          construct: .verbal,    template: .choice,    trials: 16, description: "A:B :: C:? pattern",                        isPremium: false),
        .init(id: .sentence,     name: "Sentence Complete",  construct: .verbal,    template: .choice,    trials: 16, description: "Best-fit word",                             isPremium: false),
        .init(id: .vocab,        name: "Vocabulary",         construct: .verbal,    template: .choice,    trials: 16, description: "Define words",                              isPremium: false),
        .init(id: .verbfluency,  name: "Verbal Fluency",     construct: .verbal,    template: .typed,     trials: 1,  description: "Words starting with letter",                isPremium: false),
        .init(id: .category,     name: "Category Fluency",   construct: .verbal,    template: .typed,     trials: 1,  description: "Category members",                          isPremium: false),

        // ── Problem-Solving (5) ──
        .init(id: .matrix,       name: "Matrix Reasoning",   construct: .problem,   template: .choice,    trials: 12, description: "Find the pattern",                          isPremium: false),
        .init(id: .logic,        name: "Logic",              construct: .problem,   template: .choice,    trials: 16, description: "Syllogisms",                                isPremium: false),
        .init(id: .mentalrot,    name: "Mental Rotation",    construct: .problem,   template: .choice,    trials: 16, description: "Rotate shapes",                             isPremium: false),
        .init(id: .matchpairs,   name: "Pattern Match",      construct: .problem,   template: .grid,      trials: 12, description: "Match the tile",                            isPremium: false),
        .init(id: .towers,       name: "Tower of Hanoi",     construct: .problem,   template: .sort,      trials: 8,  description: "Plan moves",                                isPremium: false),

        // ── Executive Function (5, premium) ──
        .init(id: .trailmix,     name: "Trail Making B",        construct: .executive,template: .grid,    trials: 1,  description: "Alternate number/letter",                 isPremium: true),
        .init(id: .rulefind,     name: "Rule Finding (WCST)",   construct: .executive,template: .sort,    trials: 24, description: "Sort by hidden rule",                     isPremium: true),
        .init(id: .setshift,     name: "Set Shifting",          construct: .executive,template: .choice,  trials: 16, description: "Switch categories",                       isPremium: true),
        .init(id: .planning,     name: "Planning (Zoo Map)",    construct: .executive,template: .grid,    trials: 1,  description: "Plan a route",                            isPremium: true),
        .init(id: .inhibit,      name: "Inhibition",            construct: .executive,template: .choice,  trials: 16, description: "Stop the impulse",                       isPremium: true),
    ]

    static func game(_ id: GameId) -> GameDef? {
        all.first { $0.id == id }
    }

    static func game(_ id: String) -> GameDef? {
        GameId(rawValue: id).flatMap(game)
    }

    static func grouped<T: Hashable>(by keyPath: KeyPath<GameDef, T>) -> [T: [GameDef]] {
        Dictionary(grouping: all, by: { $0[keyPath: keyPath] })
    }
}
