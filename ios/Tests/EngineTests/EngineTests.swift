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
}
