import XCTest
@testable import Upmind

@MainActor
final class OnboardingFlowViewModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "Upmind.OnboardingComplete")
    }

    func testInitialStepIsWelcome() {
        let vm = OnboardingFlowViewModel()
        XCTAssertEqual(vm.currentStep, .welcome)
    }

    func testAdvanceMovesToNextStep() {
        let vm = OnboardingFlowViewModel()
        vm.advance()
        XCTAssertEqual(vm.currentStep, .value)
        vm.advance()
        XCTAssertEqual(vm.currentStep, .survey)
        vm.advance()
        XCTAssertEqual(vm.currentStep, .briefing)
        vm.advance()
        XCTAssertEqual(vm.currentStep, .paywall)
        vm.advance()
        // No step after paywall — stays at paywall
        XCTAssertEqual(vm.currentStep, .paywall)
    }

    func testSkipSetsUserDefaultsFlag() {
        let vm = OnboardingFlowViewModel()
        vm.skip()
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "Upmind.OnboardingComplete"))
    }
}
