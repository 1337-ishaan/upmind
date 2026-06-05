import Foundation
import UserNotifications
import Observation

@MainActor
@Observable
final class NotificationCenterService {
    private(set) var permissionState: PermissionState = .notDetermined

    var categoryOptIn: [NotificationCategory: Bool] {
        didSet { persistOptIn() }
    }

    private let center = UNUserNotificationCenter.current()
    private let optInKey = "Upmind.NotificationOptIn"

    init() {
        let defaults = UserDefaults.standard
        var initial: [NotificationCategory: Bool] = [:]
        for c in NotificationCategory.allCases {
            if defaults.object(forKey: "\(optInKey).\(c.rawValue)") == nil {
                initial[c] = c.defaultOptIn
            } else {
                initial[c] = defaults.bool(forKey: "\(optInKey).\(c.rawValue)")
            }
        }
        self.categoryOptIn = initial
    }

    func refreshPermissionState() async {
        let settings = await center.notificationSettings()
        permissionState = PermissionState(settings.authorizationStatus)
    }

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await refreshPermissionState()
            return granted
        } catch {
            return false
        }
    }

    func rescheduleAll() async {
        center.removeAllPendingNotificationRequests()
        guard permissionState == .granted || permissionState == .provisional else { return }

        for category in NotificationCategory.allCases {
            guard categoryOptIn[category] == true else { continue }
            let request = makeRequest(for: category)
            try? await center.add(request)
        }
    }

    func pauseAllFor24Hours() {
        center.removeAllPendingNotificationRequests()
    }

    private func makeRequest(for category: NotificationCategory) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = category.userFacingTitle
        content.body = defaultBody(for: category)
        content.threadIdentifier = category.threadIdentifier
        content.sound = .default

        let trigger: UNNotificationTrigger
        switch category {
        case .streakRescue:
            var date = DateComponents()
            date.hour = 20; date.minute = 0
            trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        case .dailyDrill:
            var date = DateComponents()
            date.hour = 9; date.minute = 0
            trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        case .weeklyRecap:
            var date = DateComponents()
            date.weekday = 1; date.hour = 19; date.minute = 0
            trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        case .premiumRenewal:
            let fireDate = Date().addingTimeInterval(3 * 86400)
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        case .premiumLapse:
            let fireDate = Date().addingTimeInterval(86400)
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        }
        let request = UNNotificationRequest(
            identifier: "upmind.\(category.rawValue)",
            content: content,
            trigger: trigger
        )
        return request
    }

    private func defaultBody(for category: NotificationCategory) -> String {
        switch category {
        case .streakRescue:    return "Don't break your streak — play today's 3-minute drill."
        case .dailyDrill:      return "Your daily 3-minute drill is ready."
        case .weeklyRecap:     return "Here's how you trained this week."
        case .premiumRenewal:  return "Your Upmind Premium renews in 3 days."
        case .premiumLapse:    return "Your premium access ended today. Tap to see what you had."
        }
    }

    private func persistOptIn() {
        for (category, enabled) in categoryOptIn {
            UserDefaults.standard.set(enabled, forKey: "\(optInKey).\(category.rawValue)")
        }
    }
}
