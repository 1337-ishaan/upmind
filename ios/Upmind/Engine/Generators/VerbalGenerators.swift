import Foundation

// MARK: - Verbal construct

/// Generators for the six Verbal games. The construct measures vocabulary,
/// semantic relations (synonyms, analogies), sentence comprehension, and
/// productive fluency (typed verbal/category fluency).
enum VerbalGenerators {

    /// Synonyms: pick the synonym for the cue word.
    static let Synonyms: any TrialGenerator = SynonymsGenerator()

    /// Analogies: A : B :: C : ? — pick the word that completes the analogy.
    static let Analogies: any TrialGenerator = AnalogiesGenerator()

    /// Sentence Complete: pick the best-fit word for a sentence with a blank.
    static let SentenceComplete: any TrialGenerator = SentenceCompleteGenerator()

    /// Vocabulary: pick the definition of a cue word.
    static let Vocabulary: any TrialGenerator = VocabularyGenerator()

    /// Verbal Fluency: type as many words as you can starting with a letter.
    static let VerbalFluency: any TrialGenerator = VerbalFluencyGenerator()

    /// Category Fluency: type as many members of a category as you can.
    static let CategoryFluency: any TrialGenerator = CategoryFluencyGenerator()

    // MARK: - Concrete generators

    struct SynonymsGenerator: TrialGenerator {
        private let pairs: [(cue: String, syn: String)] = [
            ("Happy",  "Joyful"),
            ("Big",    "Large"),
            ("Fast",   "Quick"),
            ("Smart",  "Intelligent"),
            ("Brave",  "Courageous"),
            ("Quiet",  "Silent"),
            ("Rich",   "Wealthy"),
            ("Strong", "Powerful")
        ]
        // Filler that is never a synonym of any cue above.
        private let filler: [String] = ["Cold", "Round", "Sleepy", "Empty",
                                        "Heavy", "Tall", "Sour", "Hollow"]

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let i = rng.int(upperBound: pairs.count)
            let cue = pairs[i].cue
            let syn = pairs[i].syn
            // Distractor: a synonym from a *different* pair.
            let dIdx = (i + 1 + rng.int(upperBound: pairs.count - 1)) % pairs.count
            let distractor = pairs[dIdx].syn
            let unrelated = filler[rng.int(upperBound: filler.count)]
            let shuffled = rng.shuffled([
                Choice(id: "correct",  label: syn,        correct: true),
                Choice(id: "near",     label: distractor, correct: false),
                Choice(id: "filler",   label: unrelated,  correct: false)
            ])
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "Synonym for \(cue)?",
                choices: shuffled, mode: nil
            ))
        }
    }

    struct AnalogiesGenerator: TrialGenerator {
        // A : B :: C : answer
        private let items: [(a: String, b: String, c: String, answer: String)] = [
            ("Hand",    "Glove",   "Foot",   "Sock"),
            ("Bird",    "Feather", "Fish",   "Scale"),
            ("Day",     "Sun",     "Night",  "Moon"),
            ("Doctor",  "Hospital","Teacher","School"),
            ("Kitten",  "Cat",     "Puppy",  "Dog"),
            ("Up",      "Down",    "Left",   "Right")
        ]
        private let filler: [String] = ["Tree", "Bread", "Chair", "Rain",
                                        "Stone", "Music"]

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let i = rng.int(upperBound: items.count)
            let item = items[i]
            // Pick distractor as another item's answer, but never equal to ours.
            var dIdx = (i + 1 + rng.int(upperBound: items.count - 1)) % items.count
            while items[dIdx].answer == item.answer { dIdx = (dIdx + 1) % items.count }
            let distractor = items[dIdx].answer
            let extra = filler[rng.int(upperBound: filler.count)]
            let shuffled = rng.shuffled([
                Choice(id: "correct",    label: item.answer, correct: true),
                Choice(id: "distractor", label: distractor,  correct: false),
                Choice(id: "filler",     label: extra,       correct: false)
            ])
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "\(item.a) is to \(item.b) as \(item.c) is to ?",
                choices: shuffled, mode: nil
            ))
        }
    }

    struct SentenceCompleteGenerator: TrialGenerator {
        private let items: [(sentence: String, correct: String, d1: String, d2: String)] = [
            ("The sky is ___ today.",                "Cloudy",  "Red",  "Loud"),
            ("I ___ my teeth every morning.",        "Brush",   "Eat",  "Read"),
            ("She ___ to music every day.",          "Listens", "Eats", "Runs"),
            ("The opposite of hot is ___.",          "Cold",    "Warm", "Fast"),
            ("Dogs are known to be very ___.",       "Loyal",   "Tall", "Yellow"),
            ("Books are kept on the ___.",           "Shelf",   "Floor (wet)", "Sky")
        ]

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let i = rng.int(upperBound: items.count)
            let item = items[i]
            let shuffled = rng.shuffled([
                Choice(id: "correct", label: item.correct, correct: true),
                Choice(id: "d1",      label: item.d1,      correct: false),
                Choice(id: "d2",      label: item.d2,      correct: false)
            ])
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: item.sentence, choices: shuffled, mode: nil
            ))
        }
    }

    struct VocabularyGenerator: TrialGenerator {
        private let items: [(word: String, def: String, d1: String, d2: String)] = [
            ("Ephemeral",  "Lasting a short time",  "Permanent",   "Flowing"),
            ("Ubiquitous", "Found everywhere",      "Rare",        "Hidden"),
            ("Benevolent", "Kind and generous",     "Cruel",       "Indifferent"),
            ("Pragmatic",  "Practical",             "Idealistic",  "Theoretical"),
            ("Lucid",      "Clear and easy to follow","Confused",  "Sleepy"),
            ("Verbose",    "Using many words",      "Concise",     "Silent")
        ]

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let i = rng.int(upperBound: items.count)
            let item = items[i]
            let shuffled = rng.shuffled([
                Choice(id: "correct", label: item.def, correct: true),
                Choice(id: "d1",      label: item.d1,  correct: false),
                Choice(id: "d2",      label: item.d2,  correct: false)
            ])
            return .choice(ChoiceTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "What does \(item.word) mean?",
                choices: shuffled, mode: nil
            ))
        }
    }

    struct VerbalFluencyGenerator: TrialGenerator {
        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            // Common, generative starting letters only — never X, Q, Z.
            let letters: [Character] = Array("ABCDEFGHILMNOPRSTW")
            let letter = letters[rng.int(upperBound: letters.count)]
            return .typed(TypedTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "Type as many words as you can starting with \(letter)",
                placeholder: "apple ant arrow…",
                answerPattern: ".+"
            ))
        }
    }

    struct CategoryFluencyGenerator: TrialGenerator {
        private let categories: [String] = [
            "Fruits", "Countries", "Animals", "Sports", "Colors",
            "Musical instruments", "Vegetables", "Items in a kitchen"
        ]

        func makeTrial(index: Int, difficulty: Int) -> Trial {
            var rng = SeededRNG(seed: UInt64(bitPattern: Int64(index + 1)))
            let cat = categories[rng.int(upperBound: categories.count)]
            return .typed(TypedTrial(
                id: UUID(), index: index, difficulty: difficulty,
                prompt: "Name as many \(cat) as you can",
                placeholder: "apple banana cherry…",
                answerPattern: ".+"
            ))
        }
    }
}
