import XCTest
import UserNotifications
@testable import Upmind

@MainActor
final class NotificationCenterServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        for c in NotificationCategory.allCases {
            UserDefaults.standard.removeObject(forKey: "Upmind.NotificationOptIn.\(c.rawValue)")
        }
    }

    func testInitialOptInMatchesDefaults() {
        let service = NotificationCenterService()
        for c in NotificationCategory.allCases {
            XCTAssertEqual(service.categoryOptIn[c], c.defaultOptIn, "\(c) initial opt-in should match default")
        }
    }

    func testTogglingCategoryUpdatesUserDefaults() {
        let service = NotificationCenterService()
        service.categoryOptIn[.streakRescue] = false
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "Upmind.NotificationOptIn.streakRescue"))
    }

    func testAllCategoriesHaveUserFacingCopy() {
        for c in NotificationCategory.allCases {
            XCTAssertFalse(c.userFacingTitle.isEmpty, "\(c) missing title")
            XCTAssertFalse(c.userFacingSubtitle.isEmpty, "\(c) missing subtitle")
            XCTAssertFalse(c.threadIdentifier.isEmpty, "\(c) missing thread id")
        }
    }

    func testPermissionStateMapping() {
        XCTAssertEqual(PermissionState(.notDetermined), .notDetermined)
        XCTAssertEqual(PermissionState(.authorized), .granted)
        XCTAssertEqual(PermissionState(.provisional), .provisional)
        XCTAssertEqual(PermissionState(.ephemeral), .ephemeral)
    }
}
