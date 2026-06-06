import XCTest
@testable import Upmind

final class EngineTests: XCTestCase {

    func testGameIdHasExactly42Cases() {
        XCTAssertEqual(GameId.allCases.count, 42)
    }

    func testGameIdRoundTripsThroughRawValue() {
        for id in GameId.allCases {
            XCTAssertEqual(GameId(rawValue: id.rawValue), id)
        }
    }

    func testPremiumGameIdsAreCorrect() {
        let premium: Set<GameId> = [.trailmix, .rulefind, .setshift, .planning, .inhibit]
        XCTAssertEqual(Set(GameId.allCases.filter { $0.isPremium }), premium)
    }

    func testEngineErrorProvidesMessages() {
        XCTAssertNotNil(EngineError.unknownGame("foo").errorDescription)
        XCTAssertNotNil(EngineError.duplicateAnswer.errorDescription)
    }

    func testConstructHasExactly7Cases() {
        XCTAssertEqual(Construct.allCases.count, 7)
    }

    func testConstructOrderMatchesRnCatalog() {
        // Order matters for the radial chart and the construct filter.
        XCTAssertEqual(Construct.allCases, [
            .attention, .memory, .processing, .numeracy, .verbal, .problem, .executive
        ])
    }

    func testConstructLabelIsHumanReadable() {
        XCTAssertEqual(Construct.attention.label, "Attention")
        XCTAssertEqual(Construct.executive.label, "Executive Function")
    }

    func testTrialHasExactly8Templates() {
        XCTAssertEqual(TemplateKind.allCases.count, 8)
    }

    func testChoiceTrialStoresPromptAndChoices() {
        let t = ChoiceTrial(
            id: UUID(),
            index: 0,
            difficulty: 1,
            prompt: "Name the ink color",
            choices: [
                Choice(id: "a", label: "Red", correct: true),
                Choice(id: "b", label: "Blue", correct: false)
            ],
            mode: nil
        )
        XCTAssertEqual(t.choices.count, 2)
        XCTAssertEqual(t.choices.first(where: { $0.correct })?.label, "Red")
    }

    func testTrialEnumCarriesAssociatedValues() {
        let t = ChoiceTrial(
            id: UUID(), index: 0, difficulty: 1,
            prompt: "p", choices: [], mode: nil
        )
        let trial = Trial.choice(t)
        if case .choice(let inner) = trial {
            XCTAssertEqual(inner.prompt, "p")
        } else {
            XCTFail("Expected .choice case")
        }
    }

    func testResponseChoiceCarriesChoiceId() {
        let r = TrialResponse.choice("a")
        if case .choice(let id) = r {
            XCTAssertEqual(id, "a")
        } else {
            XCTFail("Expected .choice")
        }
    }

    func testResponseNumberLineCarriesDouble() {
        let r = TrialResponse.numberLine(0.42)
        if case .numberLine(let v) = r {
            XCTAssertEqual(v, 0.42, accuracy: 0.0001)
        } else {
            XCTFail("Expected .numberLine")
        }
    }

    func testAnswerRecordStoresAllFields() {
        let rec = AnswerRecord(
            trialIndex: 3,
            rtMs: 812,
            correct: true,
            response: .choice("a"),
            drift: false
        )
        XCTAssertEqual(rec.trialIndex, 3)
        XCTAssertEqual(rec.rtMs, 812)
        XCTAssertTrue(rec.correct)
        XCTAssertFalse(rec.drift)
    }

    func testCatalogHasExactly42Games() {
        XCTAssertEqual(Games.all.count, 42)
    }

    func testEachGameHasValidIdAndConstruct() {
        for g in Games.all {
            XCTAssertFalse(g.name.isEmpty, "\(g.id) has no name")
            XCTAssertGreaterThan(g.trials, 0, "\(g.id) has no trials")
            XCTAssertFalse(g.description.isEmpty, "\(g.id) has no description")
        }
    }

    func testCatalogMatchesGameIdCases() {
        let catalogIds = Set(Games.all.map(\.id))
        let enumIds = Set(GameId.allCases)
        XCTAssertEqual(catalogIds, enumIds, "Catalog and GameId enum must agree exactly")
    }

    func testPremiumCatalogEntriesAreExecutive() {
        let premium = Games.all.filter(\.isPremium)
        XCTAssertEqual(premium.count, 5)
        for g in premium {
            XCTAssertEqual(g.construct, .executive)
        }
    }

    func testCatalogLookupById() {
        XCTAssertEqual(Games.game(.stroop)?.name, "Stroop")
        XCTAssertNil(Games.game("fooBar"))
    }

    func testCatalogGroupedByConstruct() {
        let byConstruct = Games.grouped(by: \.construct)
        XCTAssertEqual(byConstruct[.attention]?.count, 7)
        XCTAssertEqual(byConstruct[.memory]?.count, 7)
        XCTAssertEqual(byConstruct[.processing]?.count, 5)
        XCTAssertEqual(byConstruct[.numeracy]?.count, 7)
        XCTAssertEqual(byConstruct[.verbal]?.count, 6)
        XCTAssertEqual(byConstruct[.problem]?.count, 5)
        XCTAssertEqual(byConstruct[.executive]?.count, 5)
    }

    func testGeneratorProtocolExposesMakeTrial() {
        // Concrete test for the protocol: any conforming type can be invoked.
        struct Dummy: TrialGenerator {
            func makeTrial(index: Int, difficulty: Int) -> Trial {
                .choice(ChoiceTrial(
                    id: UUID(),
                    index: index,
                    difficulty: difficulty,
                    prompt: "p",
                    choices: [Choice(id: "a", label: "A", correct: true)],
                    mode: nil
                ))
            }
        }
        let g = Dummy()
        let trial = g.makeTrial(index: 0, difficulty: 1)
        XCTAssertEqual(trial.index, 0)
        XCTAssertEqual(trial.difficulty, 1)
    }

    func testGeneratorRegistryLooksUpByGameId() {
        // The registry should return a non-nil generator for every GameId.
        // Plan 2 will fill in the real generators; for now we just need the lookup path.
        for id in GameId.allCases {
            XCTAssertNotNil(Generators.lookup(id), "Missing generator for \(id)")
        }
    }
}
